# Downloads dill files from CIPD for each supported ABI version.

import os
import subprocess
import sys
import utils


def procWait(p):
  while p.returncode is None:
    p.communicate()
    p.poll()
  return p.returncode


def findAbiVersion(version):
  cmd = ['cipd', 'instances', 'dart/abiversions/%d' % version]
  p = subprocess.Popen(cmd,
                       stdout = subprocess.PIPE,
                       stderr = subprocess.PIPE,
                       shell = utils.IsWindows(),
                       cwd = utils.DART_DIR)
  return procWait(p) == 0


def downloadAbiDills(oldest_abi_version, abi_version):
  cmd = ['cipd', 'ensure', '-root', 'tools/abiversions', '-ensure-file', '-']
  ensure_file = ''
  for i in xrange(oldest_abi_version, abi_version + 1):
    ensure_file += '@Subdir %d\ndart/abiversions/%d latest\n\n' % (i, i)
  if not ensure_file:
    return 0
  p = subprocess.Popen(cmd,
                       stdin = subprocess.PIPE,
                       stdout = subprocess.PIPE,
                       stderr = subprocess.PIPE,
                       shell = utils.IsWindows(),
                       cwd = utils.DART_DIR)
  p.communicate(ensure_file)
  p.stdin.close()
  return procWait(p)


def main():
  abi_version = int(utils.GetAbiVersion())
  oldest_abi_version = int(utils.GetOldestSupportedAbiVersion())

  # The latest abi versions may not have an entry in CIPD yet, so check first.
  while abi_version >= oldest_abi_version:
    if findAbiVersion(abi_version):
      break
    abi_version -= 1

  return downloadAbiDills(oldest_abi_version, abi_version)


if __name__ == '__main__':
  sys.exit(main())
