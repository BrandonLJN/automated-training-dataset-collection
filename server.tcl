# start X:/
set read_from ""
set write_to  ""
set stat_file ""
set mon_time_interval 500
set last_stat 1

proc eval_cmd {read_from write_to stat_file} {
    upvar last_stat last_stat

	set chan [open $stat_file r]
    set stat [read $chan]
	close $chan

    if { $last_stat == $stat } { # no new commands are available
        return
    }
	
    # read command 
	set chan [open $read_from r]
	set cmd [read $chan]
	close $chan	
	
    # execute command
    catch {$cmd} res

    # write results to file
	set chan [open $write_to w]
	puts $chan $res
	close $chan	

    # update state
	set chan [open $stat_file w]
    set stat [expr ($stat+1)%2] 
    puts $chan $stat
	close $chan
    
    set last_stat $stat
}

proc start {dir} {
	upvar read_from read_from
	upvar write_to  write_to 
	upvar stat_file stat_file 
    upvar mon_time_interval mon_time_interval
    upvar last_stat last_stat

    puts "server starting at $dir"

	set read_from [file join $dir to_nav.txt]
	set write_to  [file join $dir from_nav.txt]
	set stat_file [file join $dir stat.txt]
	
    set chan [open $read_from w]
    close $chan	

    set chan [open $stat_file w]
    puts $chan $last_stat
    close $chan

	while {1} {
		set t0 [clock clicks -millisec]
        eval_cmd $read_from $write_to $stat_file
		set eta [expr {([clock clicks -millisec]-$t0)}]
        if { [expr $mon_time_interval-$eta > 0] } {
		    after [expr $mon_time_interval-$eta]
		    set dumy 0
        }
	}
}

puts "server.tcl is sourced"
