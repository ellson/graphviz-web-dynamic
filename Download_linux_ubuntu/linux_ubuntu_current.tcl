#!/usr/bin/tclsh
                                                                                
set docroot /var/www/www.graphviz.org

set releases {
    "current stable release<br>" pub/graphviz/stable
    "development snapshot<br>(If red, then they are more than 36 hours old<br>and we have a problem with the latest snapshot.)" pub/graphviz/development
}

set packages_platforms {
    graphviz {UB13.10.x86_64 UB13.10.i386 UB12.04.x86_64 UB12.04.i386}
}

set platform_directory_type_comments {
    UB13.10.x86_64 ubuntu/ub13.10/x86_64 {amd64.deb all.deb} "Ubuntu 13.10 (Saucy Salamander)"
    UB13.10.i386 ubuntu/ub13.10/i386 {i386.deb all.deb} "Ubuntu 13.10 (Saucy Salamander)"
    UB12.04.x86_64 ubuntu/ub12.04/x86_64 {amd64.deb all.deb} "Ubuntu 12.04 (Precise Pangolin)"
    UB12.04.i386 ubuntu/ub12.04/i386 {i386.deb all.deb} "Ubuntu 12.04 (Precise Pangolin)"
    UB11.04.x86_64 ubuntu/ub11.04/x86_64 {amd64.deb all.deb} "Ubuntu 11.04 (Natty Narwhal)"
    UB11.04.i386 ubuntu/ub11.04/i386 {i386.deb all.deb} "Ubuntu 11.04 (Natty Narwhal)"
    UB10.10.x86_64 ubuntu/ub10.10/x86_64 {amd64.deb all.deb} "Ubuntu 10.10 (Maverick Meerkat)"
    UB10.10.i386 ubuntu/ub10.10/i386 {i386.deb all.deb} "Ubuntu 10.10 (Maverick Meerkat)"
    UB9.04.x86_64 ubuntu/ub9.04/x86_64 {amd64.deb all.deb} "Ubuntu 9.04 (Jaunty Jackalope)"
    UB9.04.i386 ubuntu/ub9.04/i386 {i386.deb all.deb} "Ubuntu 9.04 (Jaunty Jackalope)"
    UB8.10.i386 ubuntu/ub8.10/i386 {i386.deb all.deb} "Ubuntu 8.10 ((Intrepid Ibex))"
}


set package_exclude {
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
    set regexp {([-a-zA-Z0-9]*)_([-0-9.]*)([~a-zA-Z]*)_([a-z][.a-z0-9_]*)}
    if {![file exists $docroot/$dir]} {
#        puts $fout "<font color=\"red\">Directory \"$docroot/$dir/\" was not found.</font>"
        puts $fout "<font color=\"red\">Not Available</font><br>"
        return
    }
    set owd [pwd]
    cd $docroot/$dir
    foreach {fn n v z t} [regexp -all -inline $regexp [glob -nocomplain *]] {
        if {[file isdir $fn]} {continue}
        set exclude_this 0
        foreach {excl} $package_exclude {
            incr exclude_this [string match $excl $fn]
        }
        if {$exclude_this} {continue}
#        if {[string first $package $fn] == 0} {
            lappend PACKAGE([list $n $t]) [list $fn $v]
#        }
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

set fout [open Download_linux_ubuntu.ht w]

#Place any web server edits after the line containing cut1 and before the line containing cut2
puts $fout {
<!-- cut1 -->
<!-- Do not remove this comment or make any web server edits above this comment -->
<p><font size="+1">A development snapshot can be downloaded from launchpad.net and thereafter updated using the 'sudo apt-get update' command.  Instructions for using Launchpad are found <a href="https://launchpad.net/~gviz-adm/+archive/graphviz-dev">here</a>.</font></p>

<!-- Do not remove this comment or make any web server edits below this comment -->
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
