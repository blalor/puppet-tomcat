Quick and dirty Puppet module for Tomcat

I'm using this for one of my projects, but someone asked that I share it.  It
depends on Tomcat being installed as a package into `/opt/tomcat`.  The contents
of `/opt/tomcat` are never touched.  Instead, one or more `$CATALINA_BASE`s are
created which use the JARs and shared config of the installed package.

My usage pattern requires that Tomcat be used to serve a single WAR, but I don't
think there's anything in here that mandates that pattern.

Tested only with Ubuntu Precise, but shouldn't need much work for other
distributions aside from the startup script.  This module provides an upstart
script.

Sample usage:
    
    tomcat::base {'MyTomcatBase':
        initial_heap => 435,
        max_heap     => 1024,
        max_perm_gen => 512,
    }

WARs then get put into `/opt/local/tomcat/MyTomcatBase/webapps`.  Auto-deploy is
disabled, so you must do `service tomcat-MyTomcatBase restart` after dropping
the WAR into the `webapps` dir.
