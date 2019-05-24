#!/usr/bin/env python3

import unittest
from testpack_helper_library.unittests.dockertests import Test1and1Common


class Test1and1BaseImage(Test1and1Common):

    # <tests to run>

    def test_docker_logs(self):
        expected_log_lines = [
            "run-parts: executing /hooks/entrypoint-pre.d/00_check_euid",
            "run-parts: executing /hooks/entrypoint-pre.d/01_ssmtp_setup",
            "run-parts: executing /hooks/entrypoint-pre.d/02_user_group_setup",
            "run-parts: executing /hooks/supervisord-pre.d/20_configurability"
        ]
        container_logs = self.container.logs().decode('utf-8')
        for expected_log_line in expected_log_lines:
            self.assertTrue(
                container_logs.find(expected_log_line) > -1,
                msg="Docker log line missing: %s from (%s)" % (expected_log_line, container_logs)
            )

    def test_OS(self):
        lines = self.execRun("cat /etc/debian_version")
        self.assertTrue(lines.find("9.") > -1, msg="Failed to establish correct version")

    def test_id(self):
        self.assertEqual("10000", self.execRun("whoami")[:-1])

    def test_supervisor(self):
        self.assertPackageIsInstalled("supervisor")

        self.assertTrue(
            self.execRun("ps -ef").find('supervisord') > -1,
            msg="supervisord not running"
        )

        self.assertFalse(
            self.execRun("ls -l /etc/supervisor/supervisord.conf").find("No such file or directory") > -1,
            msg="/etc/supervisor/supervisord.conf is missing"
        )

    def test_vim(self):
        self.assertPackageIsInstalled("vim")

    def test_curl(self):
        self.assertPackageIsInstalled("curl")

    def test_bzip2(self):
        self.assertPackageIsInstalled("bzip2")

    def test_apt(self):
        self.assertTrue(
            self.execRun("ls -l /var/lib/apt/lists").find("total 0") > -1,
            msg="/var/lib/apt/lists should be empty"
        )

    # </tests to run>

if __name__ == '__main__':
    unittest.main(verbosity=1)
