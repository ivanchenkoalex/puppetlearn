class mytest {

# install vim
  package { 'vim':
    ensure => 'present',
  }

# install pip
  package { 'python2-pip':
    ensure => 'present',
  }
  ~> exec {'Install GeoIP throught pip':
    command => '/usr/bin/pip install GeoIP'
  }

# create file with content

# create dirs first
  file { [ '/etc/knative', ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $hostname = $facts['fqdn']
  $osfamily = $facts['osfamily']

  $testcontent = inline_template("HOSTNAME=<%= @hostname %>
OSFAMILY=<%= @osfamily %>
")

  file { '/etc/knative/settings.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0775',
    content => $testcontent,
  }


# install nginx
  package { 'nginx':
    ensure => present,
#    notify  => Exec['nginx_postinstall'],
  }
#  ~> exec { 'nginx_postinstall':
#    command => '/usr/sbin/nginx',
#  }

  file { '/usr/share/nginx/html/index.html':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx'],
    source  => '/work/test.html'
  }

}

class {'mytest': }

