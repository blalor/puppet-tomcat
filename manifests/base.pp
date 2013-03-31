# @todo rotate logs
define tomcat::base (
    $owner = hiera('app_user'),
    $initial_heap,
    $max_heap,
    $max_perm_gen,
    $classpath = [],
    $enable_manager = false,
) {
    require tomcat

    $catalina_base = "${tomcat::base_catalina_base}/${name}"
    $service_name = "tomcat-${name}"

    ## all files/directories in this scope should have the appropriate owner
    File {
        owner => $owner,
        group => $owner,
    }

    ## create skeleton directory for CATALINA_BASE
    file {[
        "${catalina_base}",
        "${catalina_base}/bin",
        "${catalina_base}/conf",
        "${catalina_base}/conf/Catalina",
        "${catalina_base}/conf/Catalina/localhost",
        "${catalina_base}/logs",
        "${catalina_base}/temp",
        "${catalina_base}/webapps",
    ]:
        ensure => directory,
    }

    file {"${catalina_base}/conf/logging.properties":
        source => "/opt/tomcat/conf/logging.properties",
    }

    ## setenv.sh configures most of tomcat for us
    file {"${catalina_base}/bin/setenv.sh":
        content => template('tomcat/setenv.sh.erb'),
    }

    file {"${catalina_base}/conf/server.xml":
        content => template('tomcat/server.xml.erb'),
    }

    file {"/etc/init/${service_name}.conf":
        content => template('tomcat/upstart.conf'),
    }

    ## completely enable or disable the manager app, per configuration

    $manager_context = "${catalina_base}/conf/Catalina/localhost/manager.xml"
    $tomcat_users = "${catalina_base}/conf/tomcat-users.xml"

    if $enable_manager {
        file {$manager_context:
            source => 'puppet:///modules/tomcat/manager.xml',
        }

        file {$tomcat_users:
            content => template('tomcat/tomcat-users.xml.erb'),
        }
    } else {
        ## make sure the files are deleted
        file {[ $manager_context, $tomcat_users ]:
            ensure => absent,
        }
    }

    service {$service_name:
        enable => true,
        ensure => running,

        subscribe => [
            File["/etc/init/${service_name}.conf"],
            File["${catalina_base}/bin/setenv.sh"],
            File["${catalina_base}/conf/server.xml"],
            File["${manager_context}"],
            File["${tomcat_users}"],
        ],
    }
}
