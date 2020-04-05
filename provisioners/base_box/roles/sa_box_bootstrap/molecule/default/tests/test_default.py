import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_user(host):
    with host.sudo():
        user = host.user("webmaster")
        assert user.exists
        assert user.name == "webmaster"
        assert user.groups == ["webmaster", "sudo"]
        assert user.password == "$6$3.MZlCd4j95CW0AG$pBUdQ5jFq1dxxBoLDbTAoLXqU370Vd96swB4KvyMQ7wKiHQIlW6XmA1xNpOPVXieZPQpg2HrOVYQeUzQK1Nv11"


