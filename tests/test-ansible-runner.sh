#!/bin/bash -ex

tmpdir=$(mktemp -d)

export test_env="runner_test"

runner_path="roles/ansible-runner/files/usr/local/bin/ansible-runner"
test_file="$tmpdir/ansible_runner_test_file"
test_log_dir="$tmpdir/logs"
repo="$tmpdir/ansible_runner_env_repo"
repo_playbook="$repo/ansible_runner_test.yml"
repo_checkout="$tmpdir/runner_test"
test_venv="$tmpdir/venv"

trap 'sudo rm -rf $tmpdir' EXIT

mkdir "$repo"
mkdir "$test_log_dir"

virtualenv "$test_venv"

function run_runner() {
  echo "Running ansible-runner, expecting to run playbook:"
  cat "$repo_playbook"
  mkdir -p "$test_log_dir"
  ANSIBLE_RUNNER_ENV_ROOT="$tmpdir" \
  ANSIBLE_RUNNER_VENV="$test_venv" \
  ANSIBLE_RUNNER_LOG_DIR="$test_log_dir" \
  ANSIBLE_PLAYBOOK=$(basename "$repo_playbook") \
  ANSIBLE_INVENTORY=/dev/null \
  "$runner_path" runner_test
}

function commit_requirement() {
  path="$1"
  requirement="$2"
  echo "$requirement" >> "$path"
  (
    cd "$repo" && git add . &&
    git config user.name "Anne Bonny" &&
    git config user.email "anne@bonnyci.org" &&
    git commit -a -m "Add requirement: $requirement"
  )
}

function assert_requirement() {
  requirement="$1"
  venv="$2"
  # Ensure the requirement has been successfully installed into the expected
  # virtualenv
  echo "Asserting $requirement has been installed into $venv..."
  # shellcheck disable=SC2086
  exists="$($venv/bin/pip list --format=legacy | grep $requirement)"
  if [ -z "$exists" ]; then
    echo "ERROR: Expected new requirement $requirement not installed in $venv"
    echo "Installed libraries:"
    "$venv"/bin/pip list --format=legacy
  fi
  echo "OK"
}

function commit_playbook() {
  path="$1"
  test_file="$2"
  content="$3"
  log_string="$4"
  cp tests/files/ansible_runner_test.yml "$path"
  sed -i "s,%%TEST_FILE_PATH%%,$test_file,g"  "$path"
  sed -i "s,%%TEST_FILE_CONTENT%%,$content,g"  "$path"
  sed -i "s,%%TEST_LOG_STRING%%,$log_string,g" "$path"
  (
    cd "$repo" && git add . &&
    git config user.name "Anne Bonny" &&
    git config user.email "anne@bonnyci.org" &&
    git commit -a -m "$content"
  )
}

function assert_contents_and_logging() {
    file="$1"
    contents="$2"
    log_dir="$3"
    log_string="$4"
    echo "Asserting file $file contains contents \"$contents\"... "
    if ! grep -q "$contents" "$file"; then
        echo "ERROR: Did not find expected to find contents \"$contents\" in $file"
        echo "Actual contents: "
        cat "$file"
        exit 1
    fi
    echo "OK"
    echo "Asserting latest logfile contains contents \"$log_string\"...."
    if ! grep -q "$log_string" "$log_dir"/*latest.log; then
        echo "ERROR: Did not find expected log string \"$contents\" in $log_dir"
        echo "Actual contents: "
        cat "$log_dir"/*latest.log
        exit 1
    fi
    echo "OK"
}


# Initialize the upstream environment repo from which ansible-runner will pull
# and run
git init "$repo"

# Add ansible to repo's requirements, ensuring runner installs it properly
commit_requirement "$repo"/requirements.txt ansible

# Add the playbook with given inputs
commit_playbook "$repo_playbook" "$test_file" "foo" "Anne Bonny Lives!"

# Clone the upstream to the local checkout and run the runner
git clone "$repo" "$repo_checkout"
run_runner

# Ensure the expected outputs
assert_contents_and_logging "$test_file" "foo" "$test_log_dir" "Anne Bonny Lives!"

# Add another commit to the upstream repo, changing the inputs
commit_playbook "$repo_playbook" "$test_file" "bar" "Long Live Anne Bonny!"
run_runner

# Ensure the expected outputs
assert_contents_and_logging "$test_file" "bar" "$test_log_dir" "Long Live Anne Bonny!"

# Add another requirement to the upstream requirements
commit_requirement "$repo"/requirements.txt iso8601

run_runner

assert_requirement iso8601 "$test_venv"
