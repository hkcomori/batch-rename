Describe 'batch-rename.sh'

  Describe 'temporary file'
    setup() {
      testdir="$(mktemp -d)"
      cd "${testdir}"
      mkdir "Directory 1"
      mkdir -p "Directory 2/Dir 2-"{1,2}
      mkdir -p "Directory 3/Dir 3-1/Dir 3-1-"{1,2,3}
      touch "File A"
      touch "File B"
      touch "File C"
      cd -
    }
    cleanup() {
      rm -rf ${testdir}
    }
    BeforeAll 'setup'
    AfterAll 'cleanup'

    Mock nano
      cat "$1"
    End

    It 'Directory 1'
      When run script ./src/batch-rename.sh "${testdir}/Directory 1"
      The line 1 of output should eq "${testdir}/Directory 1"
    End

    It 'Directory 3'
      When run script ./src/batch-rename.sh "${testdir}/Directory 3"
      The line 1 of output should eq "${testdir}/Directory 3"
    End

    It 'File A'
      When run script ./src/batch-rename.sh "${testdir}/File A"
      The line 1 of output should eq "${testdir}/File A"
    End

    It 'File C'
      When run script ./src/batch-rename.sh "${testdir}/File C"
      The line 1 of output should eq "${testdir}/File C"
    End

    It '2 files'
      When run script ./src/batch-rename.sh \
        "${testdir}/File A" \
        "${testdir}/File B"
      The line 1 of output should eq "${testdir}/File A"
      The line 2 of output should eq "${testdir}/File B"
    End

    It 'Multiple files and directories as sort'
      When run script ./src/batch-rename.sh \
        "${testdir}/File B" \
        "${testdir}/Directory 2" \
        "${testdir}/Directory 1" \
        "${testdir}/File A"
      The line 1 of output should eq "${testdir}/Directory 1"
      The line 2 of output should eq "${testdir}/Directory 2"
      The line 3 of output should eq "${testdir}/File A"
      The line 4 of output should eq "${testdir}/File B"
    End

    It '-d option'
      When run script ./src/batch-rename.sh -d \
        "${testdir}/Directory 2" \
        "${testdir}/Directory 3"
      The line 1 of output should eq "${testdir}/Directory 2/Dir 2-1"
      The line 2 of output should eq "${testdir}/Directory 2/Dir 2-2"
      The line 3 of output should eq "${testdir}/Directory 3/Dir 3-1"
    End

    It '-r option'
      When run script ./src/batch-rename.sh -r \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The line 1 of output should eq "${testdir}/Directory 1"
      The line 2 of output should eq "${testdir}/Directory 2"
      The line 3 of output should eq "${testdir}/Directory 2/Dir 2-1"
      The line 4 of output should eq "${testdir}/Directory 2/Dir 2-2"
      The line 5 of output should eq "${testdir}/Directory 3"
      The line 6 of output should eq "${testdir}/Directory 3/Dir 3-1"
      The line 7 of output should eq "${testdir}/Directory 3/Dir 3-1/Dir 3-1-1"
      The line 8 of output should eq "${testdir}/Directory 3/Dir 3-1/Dir 3-1-2"
      The line 9 of output should eq "${testdir}/Directory 3/Dir 3-1/Dir 3-1-3"
      The line 10 of output should eq "${testdir}/File B"
    End
  End

  Describe 'rename'
    setup() {
      testdir="$(mktemp -d)"
      cd "${testdir}"
      mkdir "Directory 1"
      mkdir -p "Directory 2/Dir 2-"{1,2}
      mkdir -p "Directory 3/Dir 3-1/Dir 3-1-"{1,2,3}
      touch "File A"
      touch "File B"
      touch "File C"
      cd -
    }
    cleanup() {
      rm -rf ${testdir}
    }
    BeforeEach 'setup'
    AfterEach 'cleanup'

    Mock nano
      sed -i -e 's/ 2-/ 4-/g' "${1}"
    End

    Mock vi
      sed -i -e 's/-1-/-9-/g' "${1}"
    End

    Mock emacs
      sed -i -e 's/Dir/dir/g' "${1}"
    End

    It 'without -n option'
      When run script ./src/batch-rename.sh -r \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The path "${testdir}/Directory 1" should be directory
      The path "${testdir}/Directory 2" should be directory
      The path "${testdir}/Directory 2/Dir 4-1" should be directory
      The path "${testdir}/Directory 2/Dir 4-2" should be directory
      The path "${testdir}/Directory 3" should be directory
      The path "${testdir}/Directory 3/Dir 3-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-2" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-3" should be directory
      The path "${testdir}/File B" should be file
      The line 1 of output should eq "renamed '${testdir}/Directory 2/Dir 2-1' -> '${testdir}/Directory 2/Dir 4-1'"
      The line 2 of output should eq "renamed '${testdir}/Directory 2/Dir 2-2' -> '${testdir}/Directory 2/Dir 4-2'"
    End

    It 'with -n option'
      When run script ./src/batch-rename.sh -nr \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The path "${testdir}/Directory 1" should be directory
      The path "${testdir}/Directory 2" should be directory
      The path "${testdir}/Directory 2/Dir 4-1" should be directory
      The path "${testdir}/Directory 2/Dir 4-2" should be directory
      The path "${testdir}/Directory 3" should be directory
      The path "${testdir}/Directory 3/Dir 3-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-2" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-3" should be directory
      The path "${testdir}/File B" should be file
      The line 1 of output should eq "renamed '${testdir}/Directory 2/Dir 2-1' -> '${testdir}/Directory 2/Dir 4-1'"
      The line 2 of output should eq "renamed '${testdir}/Directory 2/Dir 2-2' -> '${testdir}/Directory 2/Dir 4-2'"
    End

    It '--dry-run option'
      When run script ./src/batch-rename.sh --dry-run -r \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The path "${testdir}/Directory 1" should be directory
      The path "${testdir}/Directory 2" should be directory
      The path "${testdir}/Directory 2/Dir 2-1" should be directory
      The path "${testdir}/Directory 2/Dir 2-2" should be directory
      The path "${testdir}/Directory 3" should be directory
      The path "${testdir}/Directory 3/Dir 3-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-2" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-1-3" should be directory
      The path "${testdir}/File B" should be file
      The line 1 of output should eq "renamed '${testdir}/Directory 2/Dir 2-1' -> '${testdir}/Directory 2/Dir 4-1'"
      The line 2 of output should eq "renamed '${testdir}/Directory 2/Dir 2-2' -> '${testdir}/Directory 2/Dir 4-2'"
    End

    It '-e vi option'
      When run script ./src/batch-rename.sh -r -e vi \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The path "${testdir}/Directory 1" should be directory
      The path "${testdir}/Directory 2" should be directory
      The path "${testdir}/Directory 2/Dir 2-1" should be directory
      The path "${testdir}/Directory 2/Dir 2-2" should be directory
      The path "${testdir}/Directory 3" should be directory
      The path "${testdir}/Directory 3/Dir 3-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-9-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-9-2" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-9-3" should be directory
      The path "${testdir}/File B" should be file
      The line 1 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-1' -> '${testdir}/Directory 3/Dir 3-1/Dir 3-9-1'"
      The line 2 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-2' -> '${testdir}/Directory 3/Dir 3-1/Dir 3-9-2'"
      The line 3 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-3' -> '${testdir}/Directory 3/Dir 3-1/Dir 3-9-3'"
    End

    It '--editor=vi option'
      When run script ./src/batch-rename.sh -r --editor=vi \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The path "${testdir}/Directory 1" should be directory
      The path "${testdir}/Directory 2" should be directory
      The path "${testdir}/Directory 2/Dir 2-1" should be directory
      The path "${testdir}/Directory 2/Dir 2-2" should be directory
      The path "${testdir}/Directory 3" should be directory
      The path "${testdir}/Directory 3/Dir 3-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-9-1" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-9-2" should be directory
      The path "${testdir}/Directory 3/Dir 3-1/Dir 3-9-3" should be directory
      The path "${testdir}/File B" should be file
      The line 1 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-1' -> '${testdir}/Directory 3/Dir 3-1/Dir 3-9-1'"
      The line 2 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-2' -> '${testdir}/Directory 3/Dir 3-1/Dir 3-9-2'"
      The line 3 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-3' -> '${testdir}/Directory 3/Dir 3-1/Dir 3-9-3'"
    End

    It 'rename the middle of path'
      When run script ./src/batch-rename.sh -r --editor=emacs \
        "${testdir}/Directory 3" \
        "${testdir}/Directory 1" \
        "${testdir}/File B" \
        "${testdir}/Directory 2"
      The path "${testdir}/directory 1" should be directory
      The path "${testdir}/directory 2" should be directory
      The path "${testdir}/directory 2/dir 2-1" should be directory
      The path "${testdir}/directory 2/dir 2-2" should be directory
      The path "${testdir}/directory 3" should be directory
      The path "${testdir}/directory 3/dir 3-1" should be directory
      The path "${testdir}/directory 3/dir 3-1/dir 3-1-1" should be directory
      The path "${testdir}/directory 3/dir 3-1/dir 3-1-2" should be directory
      The path "${testdir}/directory 3/dir 3-1/dir 3-1-3" should be directory
      The path "${testdir}/File B" should be file
      The line 1 of output should eq "renamed '${testdir}/Directory 1' -> '${testdir}/directory 1'"
      The line 2 of output should eq "renamed '${testdir}/Directory 2' -> '${testdir}/directory 2'"
      The line 3 of output should eq "renamed '${testdir}/Directory 2/Dir 2-1' -> '${testdir}/directory 2/dir 2-1'"
      The line 4 of output should eq "renamed '${testdir}/Directory 2/Dir 2-2' -> '${testdir}/directory 2/dir 2-2'"
      The line 5 of output should eq "renamed '${testdir}/Directory 3' -> '${testdir}/directory 3'"
      The line 6 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1' -> '${testdir}/directory 3/dir 3-1'"
      The line 7 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-1' -> '${testdir}/directory 3/dir 3-1/dir 3-1-1'"
      The line 8 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-2' -> '${testdir}/directory 3/dir 3-1/dir 3-1-2'"
      The line 9 of output should eq "renamed '${testdir}/Directory 3/Dir 3-1/Dir 3-1-3' -> '${testdir}/directory 3/dir 3-1/dir 3-1-3'"
    End
  End
End
