#!/usr/bin/tclsh
                                                                                
set docroot /var/www/www.graphviz.org

set releases {
    "current stable release<br>" pub/graphviz/stable
    "development snapshot<br>(If red, then they are more than 36 hours old<br>and we have a problem with the latest snapshot.)" pub/graphviz/development
}

set packages_platforms {
    graphviz {SRPMS FC17.i386 FC17.x86_64 FC16.i386 FC16.x86_64 FC15.i386 FC15.x86_64 FC14.i386 FC14.x86_64 FC13.i386 FC13.x86_64}
    webdot {SRPMS FC17.i386 FC17.x86_64 FC16.i386 FC16.x86_64 FC15.i386 FC15.x86_64 FC14.i386 FC14.x86_64 FC13.i386 FC13.x86_64}
}

set platform_directory_type_comments {
    SRPMS SRPMS {src.rpm} ""
    FC17.i386 redhat/fc17/i386/os {fc17.i686.rpm fc17.i586.rpm fc17.i386.rpm fc17.noarch.rpm} "Fedora 17 (Rawhide)"
    FC17.x86_64 redhat/fc17/x86_64/os {fc17.x86_64.rpm fc17.noarch.rpm} "Fedora 17 (Rawhide)"
    FC16.i386 redhat/fc16/i386/os {fc16.i686.rpm fc16.i586.rpm fc16.i386.rpm fc16.noarch.rpm} "Fedora 16"
    FC16.x86_64 redhat/fc16/x86_64/os {fc16.x86_64.rpm fc16.noarch.rpm} "Fedora 16"
    FC15.i386 redhat/fc15/i386/os {fc15.i686.rpm fc15.i586.rpm fc15.i386.rpm fc15.noarch.rpm} "Fedora 15"
    FC15.x86_64 redhat/fc15/x86_64/os {fc15.x86_64.rpm fc15.noarch.rpm} "Fedora 15"
    FC14.i386 redhat/fc14/i386/os {fc14.i686.rpm fc14.i586.rpm fc14.i386.rpm fc14.noarch.rpm} "Fedora 14"
    FC14.x86_64 redhat/fc14/x86_64/os {fc14.x86_64.rpm fc14.noarch.rpm} "Fedora 14"
    FC13.i386 redhat/fc13/i386/os {fc13.i686.rpm fc13.i586.rpm fc13.i386.rpm fc13.noarch.rpm} "Fedora 13"
    FC13.x86_64 redhat/fc13/x86_64/os {fc13.x86_64.rpm fc13.noarch.rpm} "Fedora 13"
}

set package_exclude {
    graphviz-cairo-*
    graphviz-perl-*.rhl\[789\].*
    graphviz-perl-*.el3.*
    graphviz-php-*.el\[345\].*
    graphviz-php-*.fc4.*
    graphviz-*.fc12.i386.rpm
}

set time_cutoff [expr {[clock seconds] - 36*60*60}]
proc checkdate {fnv} {
    global time_cutoff
    set color blue
    foreach {fn v} $fnv {break}
    set lst [split $v {-.}]
    if {[llength $lst] >= 5} {
        foreach {. . dt tm .} $lst {break}
        set time_stamp [clock scan [string range $dt 2 end]T${tm}00 -gmt 1]
        if {$time_stamp < $time_cutoff} {
	    set color red
        }
    }
    return [list $fn $color]
}
                                                                                
proc puts_latest {fout docroot dir package package_exclude type} {
    set regexp {([-a-zA-Z]*)([-0-9.]*)([a-z][.a-z0-9_]*)}
    if {![file exists $docroot/$dir]} {
        puts $fout "<font color=\"red\">Directory \"$docroot/$dir/\" was not found.</font>"
        return
    }
    set owd [pwd]
    cd $docroot/$dir
    foreach {fn n v t} [regexp -all -inline $regexp [glob -nocomplain *]] {
        if {[file isdir $fn]} {continue}
        set exclude_this 0
        foreach {excl} $package_exclude {
            incr exclude_this [string match $excl $fn]
        }
        if {$exclude_this} {continue}
        if {[string first $package $fn] == 0} {
            lappend PACKAGE([list $n $t]) [list $fn $v]
        }
    }
    foreach nt [array names PACKAGE] {
        foreach {n t} $nt {break}
        lappend FILES($t) [lindex [lsort -decreasing -dictionary -index 1 $PACKAGE($nt)] 0]
    }
    cd $owd
    if {[info exists FILES($type)]} {
        foreach {fnv} [lsort -dictionary -index 0 $FILES($type)] {
            foreach {fn color} [checkdate $fnv] {break}
	    if {[string first debuginfo $fn] == -1 && [string first rtest $fn] == -1} {
                puts $fout "<a href=\"/$dir/$fn\"><font color=\"$color\">$fn</font></a><br>"
	    }
	
        }
        foreach {fnv} [lsort -dictionary -index 0 $FILES($type)] {
            foreach {fn color} [checkdate $fnv] {break}
	    if {[string first debuginfo $fn] != -1 || [string first rtest $fn] != -1} {
                puts $fout "&nbsp;&nbsp;<a href=\"/$dir/$fn\"><font color=\"$color\" size=\"-2\">$fn</font></a><br>"
	    }
        }
    }
}

set fout [open Download_linux_fedora.ht w]

#puts $fout {
#<p><b>RH73</b> binaries should run on any later system.
#The primary difference is that the <b>Fedora</b> binaries use <i>fontconfig</i>.
#<p>
#}

#Place any web server edits after the line containing cut1 and before the line containing cut2
puts $fout {
<!-- cut1 -->
<!-- cut2 -->
}

puts $fout "<table frame=\"void\" rules=\"groups\" border=\"1\" width=\"100%\">"
for {set i 0} {$i <= [llength $releases] / 2} {incr i} {
    puts $fout "<colgroup><col></colgroup>"
}

foreach {package platforms} $packages_platforms {
    puts $fout "<tbody>"
    puts $fout "<tr>"
    puts $fout "<th align=\"left\"><font size=\"+1\">$package</font></th>"
    foreach {releasename releasedir} $releases {
    	puts $fout "<th><font size=\"-1\">$releasename</font></th>"
    }
    puts $fout "</tr>"
    puts $fout "</tbody>"
    foreach {platform directory types comment} $platform_directory_type_comments {
	if {[lsearch $platforms $platform] == -1} continue
        puts $fout "<tbody>"
        puts $fout "<tr><th align=\"right\"><font size=\"-1\">$platform</font></th>"
        foreach {releasename releasedir} $releases {
            puts $fout "<td align=\"left\" nowrap><font size=\"-1\">"
            foreach type $types {
                puts_latest $fout $docroot $releasedir/$directory $package $package_exclude $type
            }
            puts $fout "</font></td>"
  	}
        puts $fout "</tr>"
        puts $fout "</tbody>"
    }
    puts $fout "<tbody>"
    puts $fout "<tr><td colspan=\"[expr {1 + ([llength $releases] / 2)}]\">&nbsp;</td></tr>"
    puts $fout "</tbody>"
}

puts $fout "</table>"
	
close $fout
