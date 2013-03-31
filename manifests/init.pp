class tomcat (
    $version,
    $base_catalina_base = '/opt/local/tomcat',
) {
    package {'tomcat':
        ensure => $version,
    }

    file {$base_catalina_base:
        ensure => directory,
        mode   => 1777,
        owner  => 'root',
        group  => 'root',
    }
}
