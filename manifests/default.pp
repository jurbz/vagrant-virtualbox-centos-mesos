$mesosmaster = [ 'mesos', 'mesosphere-zookeeper', ] # Mesos master required packages
$mesosslave = 'mesos' # Mesos agent required packages
$zk = 'zk://10.0.0.101:2181/mesos' # Zookeeper string

# Mesosphere repo install
package { 'mesosphere-el-repo-7-3':
  ensure => 'installed',
  source => 'https://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-3.noarch.rpm',
  provider => 'rpm'
}

# Zookeeper config
file { 'zk':
 path => '/etc/mesos/zk',
 content => $zk,
 ensure => present,
}

if $mesos == 'master' {
  # Mesos master setup
  package { $mesosmaster: ensure => 'installed' }

   file { 'cluster':
    path => '/etc/mesos-master/cluster',
    content => 'TestCluster',
    ensure => present,
    require => Package['mesos'],
   }
   file { 'ip':
    path => '/etc/mesos-master/ip',
    content => $masterip,
    ensure => present,
    require => Package['mesos'],
   }
   file { 'hostname':
    path => '/etc/mesos-master/hostname',
    content => $masterip,
    ensure => present,
    require => Package['mesos'],
   }
   file { 'myid':
    path => '/etc/zookeeper/conf/myid',
    content => '1',
    ensure => present,
    require => Package['mesosphere-zookeeper'],
   }

   service { 'mesos-master':
    provider => systemd,
    ensure => running,
    enable => true,
    require => [
     Package['mesos'],
     File['cluster', 'ip', 'hostname', 'zk'],
    ],
   }
   service { 'zookeeper':
    provider => systemd,
    ensure => running,
    enable => true,
    require => [
     Package['mesosphere-zookeeper'],
     File['myid'],
    ],
   }
   service { 'mesos-slave':
    provider => systemd,
    enable => false,
    require => Package['mesos'],
   }
  }
  else {
  # Mesos agent setup
  package { $mesosslave: ensure => 'installed' }
   
   file { 'ip':
    path => '/etc/mesos-slave/ip',
    content => $agentip,
    ensure => present,
    require => Package['mesos'],
   }
   file { 'hostname':
    path => '/etc/mesos-slave/hostname',
    content => $agentip,
    ensure => present,
    require => Package['mesos'],
   }

   service { 'mesos-master':
    provider => systemd,
    enable => false,
    require => Package['mesos'],
   }
   service { 'mesos-slave':
    provider => systemd,
    ensure => running,
    enable => true,
    require => [
     Package['mesos'],
     File['ip', 'hostname','zk'],
   ],
   }

}
