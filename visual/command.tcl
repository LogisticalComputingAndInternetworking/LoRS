#!/usr/bin/wish

set script_root [pwd]
# put our directory first so it is found quickly 
set auto_path [ linsert $auto_path 0 "$script_root/BWidget-1.4.1" ]
package require BWidget

option add *Button.background grey80 0
option add *Frame.background grey80 0
#option add *Button.foreground orange 0

proc init_help { } {
    global xnd_help
    global env
    # set help font to be ledgable
    DynamicHelp::configure -font {Helvetica 10 bold} -delay 1000

    set help {"The Cache parameter allows you to specify the\n" \
              "maximum number of 'blocksize' allocations to \n" \
              "keep in memory in addition to those created \n" \
              "for each operating thread. Without Cache, threads\n" \
              " that have completed a download must wait to \n" \
              "release their buffer before doing more work. \n" \
              "In general, a Cache equal to your thread count \n" \
              "will help improve download performance."}
    set xnd_help(cache) [ join $help ]
    set help {"The Prebuffer parameter allows you to specify\n" \
              "how many complete download buffers must be queued\n" \
              "before they are written to the output file.  \n" \
              "This is most useful for streaming content."}
    set xnd_help(prebuffer) [ join $help ]
    set help {"Threads specifies the maximum number of concurrent\n" \
              "operations a tool will perform.  Generally, more \n" \
              "threads will mean faster performance.  The default is\n"\
              "'all' which will use as many threads as needed."}
    set xnd_help(threads) [ join $help ]
    set help {"Blocksize specifies the desired transaction size from\n" \
              "available source IBP depots.  Source mappings may be\n" \
              "larger than Blocksize."}
    set xnd_help(dl_blocksize) [ join $help ]
    set help {"Blocksize specifies the logical-blocksize of the exNode\n" \
              "mappings."}
    set xnd_help(upl_blocksize) [ join $help ]
    set help {"Blocksize specifies the desired transaction size and \n" \
              "logical-blocksize of the new copy."}
    set xnd_help(aug_blocksize) [ join $help ]
    set help {"Progress is one part of the progressive-redundancy \n" \
              "download algorithm. This value specifies how many \n" \
              "Blocksize transactions can complete after a pending\n" \
              "transaction before that Blocksize is replicated"}
    set xnd_help(progress) [ join $help ]
    set help {"Location gives a geographic hint to the LBone.  The LBone\n"\
              "sorts returned depots by their proximity to this hint."}
    set xnd_help(location) [ join $help ]
    case $env(LOCAL_OS) in {
        {linux*}
        {
            set help {"Linux, with mplayer, supports streaming\n" \
                      "MPEG, MP3, WAV, and AVI files." }
        }
        {darwin*}
        {
            set help {"Mac OS X, with vlc, supports streaming MPEG and MP3 files." }
        }
        {MSWin32*}
        {
            set help {"Windows will not support streaming without a separate download of mplayer." }
        }
    }
    set xnd_help(stream) [ join $help ]
    set help {"Redundance is one part of the progressive-redundancy\n" \
              "download algorithm.  This value specifies the maximum\n" \
              "number of simultaneous transactions which operate on\n" \
              "a given Block."}
    set xnd_help(redundance) [ join $help ]
    set help {"This parameter is a means of limiting the number of\n" \
              "transactions between any one depot.  The default value of\n" \
              "zero gives not restriction."}
    set xnd_help(max_threads) [ join $help ]
    set help {"Copies specifies the number of replicas to create."}
    set xnd_help(copies) [ join $help ]
    set help {"End to End Blocksize specifies the size of conditioning\n" \
              "withing a the Logical Blocksize of a mapping. This \n" \
              "value will not be larger than Logical Blocksize."}
    set xnd_help(e2e_blocksize) [ join $help ]
    set help {"Duration specifies the desired allocation time limit.\n" \
              "The format allows three modifiers: m, h, d for Minute\n" \
              "Hours and Days."}
    set xnd_help(duration) [ join $help ]
    set help {"Two allocation types are suppored by most IBP depots:\n" \
              "Soft and Hard.  Hard allocations are guaranteed by the\n" \
              "depot to be available for Duration time, while Soft are not."}
    set xnd_help(alloc_type) [ join $help ]
    set help {"End to End Conditioning specifies the specific \n"\
              "operations that will be applied to your data before upload" }
    set xnd_help(e2e_condition) [ join $help ]
    set help {"Maximum depots specifies the maximum number of\n" \
              "IBP depots across which your file is Uploaded."}
    set xnd_help(maxdepots) [ join $help ]
    set help {"Many IBP Depots are equipped with specialized\n" \
              "Data-Movers for interdepot transfers.  This option\n" \
              "specifies TCP datamovers."}
    set xnd_help(mcopy) [ join $help ]
    set help {"This specifies the L-Bone Server that answers resource requests\n" \
              "from the LoRS commands Upload and Add Copy." }
    set xnd_help(lboneserver) [ join $help ]
    set help {"Depending on the size of your file and your system configuration,\n" \
              "it may be necessary to limit the amount of RAM used during\n" \
              "transactions." }
    set xnd_help(memory) [ join $help ]
    set help {"Timeout applies to the maximum time to give for a command to\n" \
              "complete.  For large files a large timeout is recommended.\n" \
              "This configuration element will be eliminated in future releases."}
    set xnd_help(timeout) [ join $help ]
    set help {"The LoRS Command tools can be visualized using another\n" \
              "computer with LoRS View Map.  This parameter specifies\n" \
              "the host name or ip address of the machine running the map."}
    set xnd_help(vizhost) [ join $help ]
    set help {"The City parameter is valid for 'state=' and 'country=' only."}
    set xnd_help(loc_city) [ join $help ]
    set help {"The balance parameter guarantees at least as many valid copies\n" \
              "as the 'copies' parameter."}
    set xnd_help(balance) [ join $help ]
    set help { "The 'new copy' parameter writes only the new copies to\n" \
              "the output exNode.  The source exNode is not modified." }
    set xnd_help(newcopy) [ join $help ]
    set help { "\n" \
              "." }
    set xnd_help(man_offset) [ join $help ]
    set help { "\n" \
              "." }
    set xnd_help(man_length) [ join $help ]

}

proc init_defaults { } {
    global xnd_command
    global env

    set dfile "$env(HOME)/.xndcommand/.xndrc"
    if { [ catch { set gf [ open $dfile r ] } ] } \
    {
        puts "COULD NOT OPEN DEFAULTS FILE!"
        set xnd_command(cango) 0
    } else {
        set x 1
        set xnd_command(cango) 1
        while { $x != -1 } {
#           puts "Reading all entries in xndrc file."
            set x [gets $gf line]
            if { $x == -1 } {
                break
            }
            set l [ split $line ]
            set cmd [lindex $l 0] 
            switch $cmd {
                GUI_VIZ_HOST
                {
                    global xnd_command
                    set xnd_command(vizhost) [ lindex $l 1 ]
                }
                GUI_ADVANCED
                {
                    global xnd_command
                    set xnd_command(adv) [ lindex $l 1 ]
                }
                XND_DIRECTORY
                {
                   set xnd_command(xnddirectory) [ join [ lrange $l 1 end ] ]
                }
                LBONE_SERVER
                {
                    global xnd_command 
                    set xnd_command(lbone_server) [lindex $l 1]
                }
                MAX_INTERNAL_BUFFER
                {
                    global xnd_command
                    set xnd_command(memory) [ lindex $l 1]
                }
                TIMEOUT
                {
                    global xnd_command
                    set xnd_command(timeout) [ lindex $l 1]
                }
                LOCATION
                {
                    global xnd_command 
                    set tmp [ join [lrange $l 1 end] ]
                    set l [ split $tmp "=" ]
#                   foreach i $l {
#                        puts "-- $i"
#                    }
                    set xnd_command(local_loc_keyword) [lindex $l 0]
                    set xnd_command(local_loc_keyword) "$xnd_command(local_loc_keyword)= "
                    set x [ split [lindex $l 1 ] ]
                    if { [ llength $x ] > 1 } {
                        set xnd_command(local_loc_value) [lindex $x 1]
                        set xnd_command(local_loc_city) [ join [ lrange $l 2 end ] ]
                    } else {
                        set xnd_command(local_loc_value) [lindex $x 1]
                        set xnd_command(local_loc_city) ""
                    }
                    puts "setting location to $xnd_command(local_loc_keyword)"
                    puts "setting location to $xnd_command(local_loc_value)"
                    puts "setting location to $xnd_command(local_loc_city)"
                     # xlkjclkj
                }
                THREADS
                {
                    global xnd_command
                    set xnd_command(threads) [lindex $l 1]
                    if { $xnd_command(threads) == -1 } {
                        set xnd_command(threads) "all"
                    }
#                   puts "setting threads to $xnd_command(threads)"
                }
                DURATION
                {
                    global xnd_command 
                    set xnd_command(duration) [lindex $l 1]
#                   puts "setting duration to $xnd_command(duration)"
                }
                COPIES
                {
                    global xnd_command 
                    set xnd_command(copies) [lindex $l 1]
                }
                STORAGE_TYPE
                {
                    global xnd_command
                    set xnd_command(alloc_type) [string tolower [lindex $l 1] ]
                }
                MAXDEPOTS
                {
                    global xnd_command
                    set xnd_command(maxdepots) [lindex $l 1]
                }
                DATA_BLOCKSIZE
                {
                    global xnd_command
                    set xnd_command(blocksize) [lindex $l 1]
                }

            }
        }
    }
}

proc exec_kill_cmd {} {
    global env
    global script_root
    puts "****************************************"
    puts "* Calling KILL on all 'xnd' processes.."
    puts "*                 and 'vlc'."
    puts "****************************************"
    #set pd [ pwd ]
    set pd $script_root
    puts "sh $pd/pkill"
    if { $env(LOCAL_OS) == "MSWin32" } {
        set z [ catch {exec $pd/../bin/pv.exe -f -k lors_* } ]
        set z [ catch {exec $pd/../bin/pv.exe -f -k lbone_* } ]
    } else {
        set z [catch {exec sh $pd/pkill lors_ } ]
        set z [catch {exec sh $pd/pkill lbone_ } ]
        set z [catch {exec sh $pd/pkill vlc} ]
    }
}
proc toggle_help_tips { win } {
    global xnd_command
    if { $xnd_command(helptip_on) == 0 } {
        $win configure -text "Turn Off Help Tips"
        set xnd_command(helptip_on) 1
        DynamicHelp::configure -enable true
    } else {
        $win configure -text "Turn On Help Tips"
        set xnd_command(helptip_on) 0
        DynamicHelp::configure -enable false
    }
}

proc create_button_box { win } {
    global xnd_command 
    set f [ frame $win.cmds ]
    button $f.quit -text Quit -command { exit } \
        -foreground red
    pack $f.quit -fill x -side left -expand yes
    button $f.kill -text Stop -command exec_kill_cmd \
        -foreground red
    pack $f.kill -fill x -side left -expand yes

#   button $f.help -text "Turn Off Help Tips" -foreground red
#   $f.help configure -command "toggle_help_tips $f.help"
#   pack $f.help -fill x -side left -expand yes

    button $f.mlist -text List -foreground red
    $f.mlist configure -command "exec_any_cmd $f.mlist" 
    set xnd_command(exec_list) $f.mlist
    pack $f.mlist -fill x -side left -expand yes

    button $f.exec -text Upload -foreground red
    $f.exec configure -command "exec_any_cmd $f.exec"
    set xnd_command(exec_button) $f.exec
    pack $f.exec -fill x -side left -expand yes

    return $f
}

proc exec_any_cmd { buttonExec } {
    global xnd_command
    global env
    global script_root
    array set map {   USA    {newusa_55_-130_25_-60_.gif} \
                      Europe {europe_70_-15_35_45_.gif} \
                      World  {newworld_85_-180_-55_180_.gif} \
                      Asia   {newworld_85_-180_-55_180_.gif} \
                      USA-EU {na-eu-world_72_-132_15_30_.gif} \
    }
    set buttonTxt [lindex [ $buttonExec configure -text ] 4]
    set bl [ split $buttonTxt ]
    if { [lindex $bl 1] == "DepotList" } {
        set buttonTxt [lindex $bl 1]
    } else {
        set buttonTxt [lindex $bl 0]
    }
    if { $buttonTxt == "Save" } {
        if { $xnd_command(local_loc_value) == "" } {
            showMessageBox .window "error" "ok" \
               "You must specify your local location before you can proceed."
            return
        }
        if { $xnd_command(cango) == 0 } {
            #set pd [ pwd ]
            set pd $script_root
            foreach index [array names map ] \
            {
                set mapfile $map($index)
                puts "configuring: $mapfile"
                set l [ split $mapfile _ ]
                set cf [ lindex $l 0 ]
                set cf "${cf}.cfg"
                set cfp "$env(HOME)/.xndcommand/$cf"

                set perlargs [ list --cmd=mapconfig --map=$mapfile --configfile=$cfp \
                                --cachefile=1 --pwdroot=$pd \
                                --depotnames=x \
                                --hidedepots=0 ]
                eval exec "perl \"$pd/run.pl\" $perlargs"
            }
        }
        set xnd_command(cango) 1
        if { $xnd_command(local_loc_city) != "" } {
            set location "$xnd_command(local_loc_keyword)$xnd_command(local_loc_value) city= $xnd_command(local_loc_city)"
        } else {
            set location "$xnd_command(local_loc_keyword)$xnd_command(local_loc_value)"
        }
        set perlargs [ list --cmd=preferences --copies=$xnd_command(copies) \
                  --location=$location --duration=$xnd_command(duration) \
                  --maxdepot=$xnd_command(maxdepots) \
                  --lboneserver=$xnd_command(lbone_server) \
                  --blocksize=$xnd_command(blocksize) \
                  --threads=$xnd_command(threads) \
                  --alloc_type=$xnd_command(alloc_type) \
                  --vizhost=$xnd_command(vizhost) \
                  --memory=$xnd_command(memory) \
                  --timeout=$xnd_command(timeout) \
                  --advanced=$xnd_command(adv) \
                  --xnddirectory=$xnd_command(xnddirectory) ]

    } elseif { $buttonTxt == "Display" } {
# refer to map array above 
        set config $xnd_command(vizconfig)
        set mapfile $map($config)
        set l [ split $mapfile _ ]
        set cf [ lindex $l 0 ]
        set cf "${cf}.cfg"
        set cfp "$env(HOME)/.xndcommand/$cf"
        set cachefile  $xnd_command(cachefile)
        set depotnames $xnd_command(depotnames) 
        if { $depotnames } {
            set depotnames "-name"
        } else {
            set depotnames "x"
        }
        set hidedepots $xnd_command(hidedepots)
        #set pd [ pwd ]
        set pd $script_root
        set perlargs [ list --cmd=ldapsearch --map=$mapfile --configfile=$cfp \
                    --cachefile=$cachefile --pwdroot=$pd \
                    --depotnames=$depotnames \
                    --hidedepots=$hidedepots ]

    } elseif { $buttonTxt == "DepotList" } {
        set x [ llength $xnd_command(listvar) ]
        if { $x <= 0 } {
            showMessageBox .window "error" "ok" \
               "Please add Depots to the DepotList before saving."
            return
        }
        set file $xnd_command(save_xndrc)
        if { [ catch { set fd [ open $file w ] } ] } {
            puts "Could not open file"
            showMessageBox .window "error" "ok" \
               "Cannot open specified file for writing."
            return
        }
        foreach i $xnd_command(listvar) {
            set l [ split $i ]
            if { [lindex $l 0] == "ROUTE" } {
                set i [ join [ list "ROUTE_DEPOT" [ lrange $l 1 end ] ] ]
            } elseif { [lindex $l 0] == "TARGET" } {
                set i [ join [ list "TARGET_DEPOT" [ lrange $l 1 end ] ] ]
            }
            puts $fd "$i"
        }
        close $fd
        return
    } elseif { $buttonTxt == "NWS" } {
        set source $xnd_command(res_source)
        if { $source == "-cache" }  \
        {
            set source "$source=$env(HOME)/.resolution.txt"
        }
        set perlargs [ list --cmd=nws --source=$source --mode=$xnd_command(res_mode) \
                    --depot=$xnd_command(depot) \
                    --lboneserver=$xnd_command(lbone_server) \
                    --vizhost=$xnd_command(vizhost) ]
    } elseif { $buttonTxt == "Route" } {
        if { $xnd_command(xnd) == "" } {
            showMessageBox .window "error" "ok" \
               "Please specify an input exnode to route."
            return
        }
        if { $xnd_command(route_depot_list_file) == "" } { 
            showMessageBox .window "error" "ok" \
               "Please specify a DepotList file for lors_route."
            return
        }
        set perlargs [ list --cmd=route --blocksize=$xnd_command(blocksize) \
                            --xndrc=$xnd_command(route_depot_list_file) \
                            --inputfile=$xnd_command(xnd) ]

    } elseif { $buttonTxt == "Upload" } {
        if { $xnd_command(open_regular) == "" } {
            showMessageBox .window "error" "ok" \
               "Please specify an input file to upload."
            return
        }
        set e2eargs ""
        if { $xnd_command(e2e_compress) == 1 } {
            set e2eargs "z"
        }
        if { $xnd_command(e2e_encrypt) == 1 } {
            set e2eargs "${e2eargs}a"
        }
        if { $xnd_command(e2e_checksum) == 1 } {
            set e2eargs "${e2eargs}k"
        }
        if { $e2eargs == "" } {
            set e2eargs "n"
        }
        if { $xnd_command(upl_loc_city) != "" } {
            set location "$xnd_command(upl_loc_keyword)$xnd_command(upl_loc_value) city= $xnd_command(upl_loc_city)"
        } else {
            set location "$xnd_command(upl_loc_keyword)$xnd_command(upl_loc_value)"
        }
        set perlargs [ list --cmd=upload --inputfile=$xnd_command(open_regular) \
                  --outputfile=$xnd_command(xnd) \
                  --copies=$xnd_command(copies) --location="$location" \
                  --duration=$xnd_command(duration) --maxdepot=$xnd_command(maxdepots) \
                  --lboneserver=$xnd_command(lbone_server) \
                  --blocksize=$xnd_command(blocksize) --threads=$xnd_command(threads) \
                  --vizhost=$xnd_command(vizhost) --memory=$xnd_command(memory) \
                  --timeout=$xnd_command(timeout) --alloc_type=$xnd_command(alloc_type) \
                  --e2eargs=$e2eargs --e2e_blocksize=$xnd_command(e2e_blocksize) \
                  --xndrc=$xnd_command(upl_depot_list_file) ]

    } elseif { $buttonTxt == "Download" } {
        if { $xnd_command(xnd) == "" } {
            showMessageBox .window "error" "ok" \
                "Please specify an input file."
            return
        }
        if { $xnd_command(stream) == 1 } {
            set cmd "play"
            set l [ split $xnd_command(xnd) "\." ]
            set ext [lindex $l end-1]

            case $env(LOCAL_OS) in {
                {linux*}
                {
                    if { $ext != "wav" && $ext != "mpg" && 
                        $ext != "mpeg" && $ext != "mp3" && $ext != "avi"} {
                        showMessageBox .window "error" "ok" \
                        "This mime type is unsupported in this Linux."
                        return
                    }
                }
                {darwin*}
                {
                    if { $ext != "mpg" && \
                        $ext != "mpeg" && $ext != "mp3" && \
                        $ext != "avi" } {
                        showMessageBox .window "error" "ok" \
                        "This mime type is unsupported in this Darwin."
                        return
                    }
                }
                {MSWin32*}
                {
                    if { $ext != "mpg" && \
                        $ext != "mpeg" && $ext != "mp3" && \
                        $ext != "avi" } {
                        showMessageBox .window "error" "ok" \
                        "This mime type is not currently supported in Windows."
                        return
                    }
                }
                {*}
                {
                    showMessageBox .window "error" "ok" "Unrecognized Platform"
                    return
                }
            }
        } else {
            set cmd "download"
            if { $xnd_command(open_regular) == "" } {
                showMessageBox .window "error" "ok" \
                "Please specify an output file."
                return
            }
        }
        exec_any_cmd $xnd_command(exec_list)
        after 1000

        set perlargs [ list --cmd=$cmd --inputfile=$xnd_command(xnd) \
                --outputfile=$xnd_command(open_regular) \
                --blocksize=$xnd_command(blocksize) \
                --threads=$xnd_command(threads) \
                --vizhost=$xnd_command(vizhost) \
                --prebuf=$xnd_command(prebuffer) \
                --cache=$xnd_command(cache) \
                --progress=$xnd_command(progress) \
                --redundance=$xnd_command(redundance) \
                --tpd=$xnd_command(tpd) \
                --offset=$xnd_command(man_offset) \
                --len=$xnd_command(man_length) ]
    } elseif { $buttonTxt == "Add_Copy" } {
        if { $xnd_command(xnd) == "" } {
            showMessageBox .window "error" "ok" \
               "Please specify an output file."
            return
        }
        if { $xnd_command(xndout) == "" } {
            showMessageBox .window "error" "ok" \
               "Please specify an output file."
            return
        }
        if { $xnd_command(aug_loc_city) != "" } {
            set location "$xnd_command(aug_loc_keyword)$xnd_command(aug_loc_value) city= $xnd_command(aug_loc_city)"
        } else {
            set location "$xnd_command(aug_loc_keyword)$xnd_command(aug_loc_value)"
        }
        if { $xnd_command(mcopy) == 1 } {
            set mc "mcopy" 
            if { $xnd_command(aug_depot_list_file) == "" } {
                showMessageBox .window "error" "ok" \
                   "Please specify an xndrc file."
                return
            }
        } else {
            set mc ""
        }
        exec_any_cmd $xnd_command(exec_list)
        after 1000
        set perlargs [ list --cmd=augment --inputfile=$xnd_command(xnd) \
                  --outputfile=$xnd_command(xndout) \
                  --copies=$xnd_command(copies) --location="$location" \
                  --duration=$xnd_command(duration) --maxdepot=$xnd_command(maxdepots) \
                  --lboneserver=$xnd_command(lbone_server) \
                  --blocksize=$xnd_command(blocksize) --threads=$xnd_command(threads) \
                  --vizhost=$xnd_command(vizhost) --timeout=$xnd_command(timeout) \
                  --mcopy=$mc --alloc_type=$xnd_command(alloc_type) \
                  --xndrc=$xnd_command(aug_depot_list_file) \
                  --balance=$xnd_command(balance) \
                  --savenew=$xnd_command(newcopy) \
                  --offset=$xnd_command(man_offset) \
                  --len=$xnd_command(man_length) ]
    } elseif { $buttonTxt == "Refresh" } {
        if { $xnd_command(xnd) == "" } {
            showMessageBox .window "error" "ok" \
               "Please specify an input file."
            return
        }
        if { $xnd_command(refresh) == "-m" } { 
            set ref_args " -m"
        } elseif { $xnd_command(refresh) == "extto" } {
            set ref_args " -s $xnd_command(duration)"
        } elseif { $xnd_command(refresh) == "extby" } {
            set ref_args " -d $xnd_command(duration)"
        }
        set duration $ref_args

        set perlargs [ list --cmd=refresh --inputfile=$xnd_command(xnd) \
                  --outputfile=$xnd_command(xnd) --duration=$duration \
                  --threads=$xnd_command(threads) \
                  --vizhost=$xnd_command(vizhost) ]
    } elseif { $buttonTxt == "Delete" } {
        if { $xnd_command(xnd) == "" } {
            showMessageBox .window "error" "ok" \
               "Please specify an input file."
            return
        }
        if { $xnd_command(trim_destructive) == 1 } {
            set trim_args "-d"
        } else {
            set trim_args "-n"
        }
        if { $xnd_command(trim_which) == "-m"  } {
            set trim_args "$trim_args -m $xnd_command(segments)" 
        }
        if { $xnd_command(trim_dead) == 1 } {
            set trim_args "$trim_args -u"
        }
        set perlargs [ list --cmd=trim --inputfile=$xnd_command(xnd) \
                  --outputfile=$xnd_command(xndout) \
                  --segs=$trim_args \
                  --threads=$xnd_command(threads) \
                  --vizhost=$xnd_command(vizhost) & ]
    } elseif { $buttonTxt == "List" } {
        if { $xnd_command(list_physical) == 1 } {
            set phy "-p"
        } else {
            set phy ""
        }
        set perlargs [ list --cmd=list --inputfile=$xnd_command(xnd) \
                  --threads=$xnd_command(threads) \
                  --physical=$phy --vizhost=$xnd_command(vizhost) ]
    } else { 
        puts "Unrecognized command"
        return
    }
    #set pd [ pwd ]
    set pd $script_root

#puts $pd
    set cmd "perl \"$pd/run.pl\" $perlargs"
    if { $buttonTxt == "Display" } {
        set x [ catch { set fd [ socket "localhost" 5240 ] } ]
        if { $x == 0 } {
            gets $fd line
            puts $fd "QUIT"
            flush $fd
        } 
        puts $cmd
        eval exec $cmd & 
    } else {
        eval exec $cmd &
        return
        puts "$cmd"
        set pipe [ open "| $cmd " r ]
        #fileevent $pipe readable [ list spinProgress $pipe ]
        fconfigure $pipe -blocking 0
        after 10 [ list spinProgress $pipe ]
        #eval exec perl $pd/run.pl $perlargs &
        #eval exec $cmd & 
    }
    #eval exec perl $pd/run.pl $perlargs &

}

proc spinProgress { pipe } {
    global xnd_command
    if { [ eof $pipe ] || [ catch { gets $pipe line} ]} {
        catch {close $pipe}
        set xnd_command(progress_var) -2
        after 500 [ list set xnd_command(progress_var) -2 ]
        return
    }
    if { $line != "" } {
        #puts "line: $xnd_command(progress_var) $line"
        incr xnd_command(progress_var) 1
    }
    after 10 [ list spinProgress $pipe ]
    update idletasks
}

proc fileDialog {w ent operation fname } {
    global xnd_command
    #   Type names                Extension(s)        Mac File Type(s)
    #---------------------------------------------------------
    set lpwd [ pwd ]
    puts "lpwd: $lpwd"
    set reg_types {
        {"All files"                  *}
        {"Media Files"                {.mp3 .mpg .mpeg .wav} }
        {"Text files"                 {.txt}            TEXT}
        {"All Source Files"           {.tcl .c .h .htm .html} }
        {"Image Files"                {.gif .jpeg .jpg} }
    }
    set xnd_types {
        {"exNode files"                {.xnd} }
        {"All files"                  *}
    }
    set xndrc_types {
        {"XNDRC File"                  {.xndrc} }
        {"All files"                  *}
    }
    set all_types {
        {"All files"                  *}
    }
    if {$operation == "open_regular"} {
          # reserved for UPLOAD
          set file [tk_getOpenFile -filetypes $reg_types -parent $w ]
        set newpwd [pwd]
        puts "newpwd: $newpwd"
        cd $newpwd
    } 
    if { $operation == "open_dir" } {
        set file [tk_chooseDirectory -mustexist 1 -parent $w ]
    }
    if { $operation == "open_xnd" } {
        cd $xnd_command(xnddirectory)
        # download / augment/ trim / refresh/ list/ play
        set file [tk_getOpenFile -filetypes $xnd_types -parent $w \
            -defaultextension .xnd \
            -initialdir $xnd_command(xnddirectory) ]
        set newpwd [pwd]
        puts "newpwd: $newpwd"
        cd $lpwd
    } 
    if { $operation == "open_xnd_download" } {
        cd $xnd_command(xnddirectory)
        # download / play
        set file [tk_getOpenFile -filetypes $xnd_types -parent $w \
            -initialdir $xnd_command(xnddirectory) ]
        set newpwd [pwd]
        puts "newpwd: $newpwd"
        cd $lpwd
    } 
    if { $operation == "open_xndrc" } {
        set file [tk_getOpenFile -filetypes $xndrc_types -parent $w \
            -defaultextension .xndrc ]
    } 
    if { $operation == "save_xndrc" } { 
        set file [tk_getSaveFile -filetypes $xndrc_types -parent $w \
            -initialfile $fname -defaultextension .xndrc ]
    }
    if { $operation == "save_xnd" } {
        # up/down/aug/trim
        cd $xnd_command(xnddirectory)
        set file [tk_getSaveFile -filetypes $xnd_types -parent $w \
            -initialfile $fname -defaultextension .xnd \
            -initialdir $xnd_command(xnddirectory) ]
        set newpwd [pwd]
        puts "newpwd: $newpwd"
        cd $lpwd
    } 
    if { $operation == "save_regular" } { 
        # reserved for DOWNLOAD 
        set file [tk_getSaveFile -filetypes $reg_types -parent $w \
            -initialfile $fname -defaultextension .xyz ]
    }
    if [string compare $file ""] {
        $ent delete 0 end
        $ent insert 0 $file
        $ent xview end
        if { $operation == "open_regular" } {
            set save_ent $w.fsave.ent
            $save_ent delete 0 end
            $save_ent insert 0 "$file.xnd"
            $save_ent xview end
        }
    }
    if { $operation == "open_xnd_download" } { 
        set l [ split $file "\." ]
        if { [lindex $l end ] == "xnd" } { 
            set short_file [ join [ lrange $l 0 end-1 ] "."]
        } else {
            set short_file $file
        }
        $fname delete 0 end
        $fname insert 0 "$short_file"
        $fname xview end
    }
}
  
proc init_all { } {
    global xnd_command 

    # restrict resizes in the vertical until we can figure out why
    # 'compute_size' doesn't work after a resize in the vertical.
    wm resizable . 1 0
    wm title . "LoRS Command"

    # add MainFrame..
    set mainFrame [ MainFrame .window -textvariable xnd_command(status) \
                        -progressvar xnd_command(progress_var) \
                        -progresstype nonincremental_infinite ]

    $mainFrame addindicator -text "LoRS Command 0.82"
    $mainFrame showstatusbar progression

    set win [ $mainFrame getframe ]
    set bbox [ create_button_box $win ]

    set t1 [ clock clicks -milliseconds ]
    # add notebook
    set notebook [NoteBook $win.notebook -tabbevelsize 4 -activebackground cornsilk ]
    set page_layout(Upload) 0
    set l [ create_req_opt_frames $notebook "Upload" "x" 1 ]
    display_upload [lindex $l 0] [lindex $l 1]
    set t2 [clock clicks -milliseconds]
    puts [ expr $t2 - $t1 ]
    set page_layout(Download) 1
    set l [ create_req_opt_frames $notebook "Download" "x" 1 ]
    display_download [lindex $l 0 ] [lindex $l 1]
    set t3 [clock clicks -milliseconds]
    puts [ expr $t3 - $t2 ]
    set page_layout(Add_Copy) 2
    set l [ create_req_opt_frames $notebook "Add_Copy" "x" 1 ]
    display_addcopy [lindex $l 0 ] [lindex $l 1]
    set t4 [clock clicks -milliseconds]
    puts [ expr $t4 - $t3 ]
    set page_layout(Refresh) 3
    set l [ create_req_opt_frames $notebook "Refresh" "x" 1 ]
    display_refresh [lindex $l 0 ] [lindex $l 1]
    set t5 [clock clicks -milliseconds]
    puts [ expr $t5 - $t4 ]
    set page_layout(Delete) 4
    set l [ create_req_opt_frames $notebook "Delete" "x" 1 ]
    display_delete [lindex $l 0 ] [lindex $l 1]
    set t6 [clock clicks -milliseconds]
    puts [ expr $t6 - $t5 ]
#set l [ create_req_opt_frames $notebook "List" "x" ]
#    display_list [lindex $l 0 ] [lindex $l 1]
    set page_layout(Other) 5
    set subnotebook [ create_page_subnotebook $notebook "Other" ]
    set t7 [clock clicks -milliseconds]
    puts [ expr $t7 - $t6 ]

    set page_layout(Preferences) 6
    set l [ create_req_opt_frames $subnotebook "Preferences" $notebook 1 ]
    display_preferences [lindex $l 0] [lindex $l 1]
    set t8 [clock clicks -milliseconds]
    puts [ expr $t8 - $t7 ]
    set page_layout(Display) 7
    set l [ create_req_opt_frames $subnotebook "Display" $notebook 1 ]
    display_display [lindex $l 0] [lindex $l 1]
    set t9 [clock clicks -milliseconds]
    puts [ expr $t9 - $t8 ]
    set page_layout(Route) 8
    set l [ create_req_opt_frames $subnotebook "Route" $notebook 0 ]
    display_route [lindex $l 0] [lindex $l 1]
    set t10 [clock clicks -milliseconds]
    puts [ expr $t10 - $t9 ]
    #set l [ create_req_opt_frames $subnotebook "NWS" $notebook 1 ]
    #display_nws [lindex $l 0] [lindex $l 1]
    set t11 [clock clicks -milliseconds]
    puts [ expr $t11 - $t10 ]
    set page_layout(DepotList) 9
    set l [ create_req_opt_frames $subnotebook "DepotList" $notebook 0 ]
    display_depotlist [lindex $l 0] [lindex $l 1]
    set t12 [clock clicks -milliseconds]
    puts [ expr $t12 - $t11 ]
    puts [ expr $t12 - $t1 ]

    pack $subnotebook -side top -fill both -expand yes -padx 0 -pady 0
    $subnotebook compute_size

    # find xnd_command(first_tab) and raise it.
    set num $page_layout($xnd_command(first_tab))
    $subnotebook raise [ $subnotebook pages 0 ]
    $notebook compute_size

    if { $num > 5 } {
        $notebook raise [ $notebook pages 5 ]
        $subnotebook raise [ $subnotebook pages [expr $num - 6] ]
    } else {
        $notebook raise [ $notebook pages $num ]
    }

    pack $notebook -side top -fill both -expand yes 
    pack $mainFrame -fill both -expand yes
    pack $bbox -side bottom -fill x
}
proc create_page_subnotebook { notebook pagename } {
    set page [ $notebook insert end $pagename -text $pagename \
            -leavecmd "do_not_go $pagename" \
      -raisecmd "toggle_run_label_major $pagename xnd_command(minor)" ]
    set subnotebook [NoteBook $page.notebook -tabbevelsize 4 -activebackground cornsilk ]
    return $subnotebook 
}

proc display_display { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME
    set subf [ $reqFrame getframe ]
    set f [frame $subf.map -background $xnd_command(bgReqColor) ]
        label $f.th_lab -text "Configuration Map : " -background $xnd_command(bgReqColor) 
        set l [ list "USA" "Europe" "Asia" "World" "USA-EU" ]
        ComboBox $f.combo -editable false -width 8 -textvariable xnd_command(vizconfig) \
                -values $l -background $xnd_command(bgReqColor) 
        pack $f.th_lab -side left -fill x 
        pack $f.combo -side left
        pack $f -side top -fill x -expand yes

    # ADVANCED FRAME
    set advf [ $advFrame getframe ]
    set subf [ frame $advf.frame -background $xnd_command(bgAdvColor) ]
    checkbutton $subf.cachefile -text "Recreate configuration file." \
                -variable xnd_command(cachefile) -background $xnd_command(bgAdvColor) 
    checkbutton $subf.depotnames -text "Display depot names." \
                -variable xnd_command(depotnames) -background $xnd_command(bgAdvColor) 
    checkbutton $subf.hidedepots -text "Hide depots beyond the map." \
                -variable xnd_command(hidedepots) -background $xnd_command(bgAdvColor)

    pack $subf.cachefile -side top -anchor w
    pack $subf.depotnames -side top -anchor w
    pack $subf.hidedepots -side top -anchor w

    pack $subf -side top -fill both -expand yes
}
proc display_route { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME
    set subf [ $reqFrame getframe ]
    set f [frame $subf.fopen -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select an exNode file to route: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd) -background white
        button $f.but -text "Browse.." -command "fileDialog $subf $f.ent open_xnd xyz"  \
                    -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top 
    set f [frame $subf.fopen_rc -background $xnd_command(bgReqColor) ]
        label $f.lab -text "DepotList file: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(route_depot_list_file) -background white
        button $f.but -text "Browse.." -command "fileDialog $subf $f.ent open_xndrc xyz"  \
                    -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top
    # ADVANCED FRAME
#    set advf [ $advFrame getframe ]
#    set subf [ frame $advf.frame -background $xnd_command(bgAdvColor) ]
    set f [ display_blocksize $subf $xnd_command(bgReqColor) $xnd_help(aug_blocksize) ]
    pack $f -side top -anchor w

#pack $subf -side left -fill y 
    return
}
proc display_depotlist { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME
    set subf [ $reqFrame getframe ] 
    set f [frame $subf.fsave  -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Save DepotList file to:" -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(save_xndrc) -background white
        button $f.but -text "Load List.." -background $xnd_command(bgReqColor) 
# button $f.load -text "Load List" -background $xnd_command(bgReqColor) 
        set load_subf $subf
        set load_f_ent $f.ent
        set load_button $f.but
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
#        pack $f.load -side right 
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    set f [ display_location $subf $xnd_command(bgReqColor) $xnd_help(location) \
            "Choose location:" \
            xnd_command(dpl_loc_keyword) xnd_command(dpl_loc_value) \
            xnd_command(dpl_loc_city) ]
    pack $f -side top -fill x

    set f [ display_maxdepots $subf $xnd_command(bgReqColor) $xnd_help(maxdepots) ]
    pack  $f -side top -fill x

    set f [frame $subf.list_possible -background $xnd_command(bgReqColor) ]
        set sw [ScrolledWindow $f.sw ]
        set lb [listbox $f.lb  -height 8 -width 25 -selectmode single]
        $sw setwidget $lb
        Button $f.update -text "Update List" -background $xnd_command(bgReqColor) \
                -command "update_depot_list $f.lb"
        pack $f.sw -side top -fill x
        pack $f.update -side top
        pack $f -side left
    set h [frame $subf.list_list -background $xnd_command(bgReqColor) ]
        set sw [ScrolledWindow $h.sw ]
        set lb [listbox $h.lb  -height 8 -width 25 -selectmode single -listvar xnd_command(listvar) ]
        $sw setwidget $lb
        radiobutton $h.depot -text "Depot" \
                -variable xnd_command(depot_type) -background $xnd_command(bgReqColor) \
                -value "DEPOT"
        radiobutton $h.route -text "Route" \
                -variable xnd_command(depot_type) -background $xnd_command(bgReqColor) \
                -value "ROUTE"
        radiobutton $h.target -text "Target" \
                -variable xnd_command(depot_type) -background $xnd_command(bgReqColor) \
                -value "TARGET"
        pack $h.sw -side top -fill both
        pack $h.depot -side left
        pack $h.route -side left
        pack $h.target -side left

        $load_button configure -command \
            "fileDialog $load_subf $load_f_ent open_xndrc $xnd_command(save_xndrc) depotlist.xndrc
            after 100 load_depot_list $lb"
    set g [frame $subf.arrow_left -background $xnd_command(bgReqColor) ]
        ArrowButton $g.right -arrowrelief raised -type button -width 25 -height 25 \
                -dir right -command "move_depot_right $f.lb $h.lb"
        $g.right configure -relief groove
        ArrowButton $g.left -arrowrelief raised -type button -width 25 -height 25 \
                -dir left -command "remove_depot_left $h.lb"
        $g.left configure -relief groove
        pack $g.right -side top
        pack $g.left -side top
        pack $g -side left
    pack $h -side left
    set i [frame $subf.arrow_updown -background $xnd_command(bgReqColor) ]
        ArrowButton $i.up -arrowrelief raised -type button -width 25 -height 25 \
                -dir top -command "move_depot $h.lb 1"
        $i.up configure -relief groove 
        ArrowButton $i.down -arrowrelief raised -type button -width 25 -height 25 \
                -dir bottom -command "move_depot $h.lb 0"
        $i.down configure -relief groove
        pack $i.up -side top
        pack $i.down -side top
        pack $i -side left

    # ADVANCED Frame
}
proc load_depot_list { lbox } {
    global xnd_command
    set file $xnd_command(save_xndrc)
    set cnt [ $lbox index end ]
    while { $cnt > 0 } { 
        incr cnt -1
        $lbox delete $cnt
    }

    if { [ catch { set gf [ open $file r ] } ] } \
    {
        showMessageBox .window "error" "ok" \
            "Please specify a DepotList file before loading."
        return
    } else {
        while { [gets $gf line] != -1 } {
            set l [ split $line ]
            case [lindex $l 0] in {
                {DEPOT}
                {
                    set dp "DEPOT"
                }
                {ROUTE_DEPOT}
                {
                    set dp "ROUTE"
                }
                {TARGET_DEPOT}
                {
                    set dp "TARGET"
                }
            }
            set i [ join [ list "$dp" [ lrange $l 1 end ] ] ]

            $lbox insert end "$i"
        }
    }
}
proc move_depot_right { list_left list_right } {
    global xnd_command
    set x [ $list_left get active ] 
    set i [ $list_left curselection ]
    puts $x
    if { $i != "" } {
        $list_right insert end "$xnd_command(depot_type) $x"
        if { [expr $i+1] != [$list_left index end] } {
            $list_left selection clear $i
            $list_left activate [expr $i+1]
            $list_left selection set [expr $i+1]
        }
    }
}
proc remove_depot_left { list_right } {
    set i [ $list_right curselection ]
    puts "curselection is $i"
    if { $i != "" } {
        $list_right delete $i
        if { $i != [$list_right index end] } {
            $list_right selection clear $i
            $list_right activate [expr $i]
            $list_right selection set [expr $i]
        }
    }
}
proc move_depot { win ud } {
    set i [ $win curselection ]
    if { $i != "" } {
        set element [ $win get active ]
        if { $ud } {
            if { $i != 0 } {
                puts "$element : $i"
                $win delete $i
                $win insert [expr $i-1] $element 
                $win selection set [expr $i-1]
                $win activate [expr $i-1]
                puts "activate -1 $i"
            }
        } else {
            if { [expr $i+1] != [$win index end] } {
                $win delete $i
                $win insert [expr $i+1] $element
                $win selection set [expr $i+1]
                $win activate [expr $i+1]
                puts "activate +1 $i"
            }
        }
    }
}
proc update_depot_list { win } { 
    global xnd_command
    set cnt [ $win index end ]
    puts "cnt: $cnt"
    puts "zoo1"
    while { $cnt > 0 } { 
        incr cnt -1
        $win delete $cnt
    }
    puts "zoo2"
    if { $xnd_command(dpl_loc_city) != "" } {
        set location "$xnd_command(dpl_loc_keyword)$xnd_command(dpl_loc_value) city= $xnd_command(dpl_loc_city)"
    } else {
        set location "$xnd_command(dpl_loc_keyword)$xnd_command(dpl_loc_value)"
    }
    puts "zoo3"
    set perlargs [ list --cmd=resolution --location=$location \
                    --maxdepots=$xnd_command(maxdepots) ]
    puts "lbone_resolution -l \"$location\" -m $xnd_command(maxdepots) -a -getcache"
    puts "zoo4"
    #set x [ exec ls -l ]
    set cmd "lbone_resolution -l \"$location\" -m $xnd_command(maxdepots) -a -getcache"
    set p [ open "| $cmd" r ]
    while { ![eof $p ] && ![ catch { gets $p line} ]} {
        if { $line != "" } {
            puts  $line
            $win insert end $line
        }
    }
    #set x [ eval exec $y ]
    puts "zoo5"
    #puts "--$x --"
    #set l [ split $x "\n" ]
    #foreach i $l {
    #    puts $i
    #    $win insert end $i
    #}
#$win insert end "galapagos.cs.utk.edu 6714" 
#    $win insert end "spoon.sinrg.cs.utk.edu 6714"
#    $win insert end "dsj.sinrg.cs.utk.edu 6714"
}
proc display_nws   { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME
    set subf [ $reqFrame getframe ] 
    set f [frame $subf.source -background $xnd_command(bgReqColor) ]
        label $f.th_lab -text "Source Depot: " -background $xnd_command(bgReqColor) 
        set l [ list \
  "adder.cs.utk.edu:6714"  \
  "angle.cs.utk.edu:6714" \
  "antipholus.cs.wisc.edu:6714"  \
  "charcoal.cs.ucsb.edu:6714"  \
  "cisa.cs.ucsb.edu:6714" \
  "coconut.cs.utk.edu:6714"  \
  "coral.cs.wisc.edu:6714"  \
  "dsj2.uits.iupui.edu:6714"  \
  "dsj2.uits.iupui.edu:6715"  \
  "acre.sinrg.cs.utk.edu:6714" \
  "fretless.cs.utk.edu:6714"  \
  "galapagos.cs.utk.edu:6714"  \
  "i2dsi.ibiblio.org:6714" \
  "i2-dsj.ibt.tamus.edu:6714"  \
  "ibanez.cs.utk.edu:6714" \
  "itas01lx.cpit.cua.edu:6714" \
  "liz.eecs.harvard.edu:6714"  \
  "magie.ucsd.edu:6714" \
  "mystere.ucsd.edu:6714" \
  "ovation.cs.utk.edu:6714"  \
  "pprg21.sas.ntu.edu.sg:6714"  \
  "quidam.ucsd.edu:6714" \
  "ramses.mfn.unipmn.it:6714"  \
  "raven.cs.ucsb.edu:6714"  \
  "silo.showcase.surfnet.nl:6714" \
  "spoon.sinrg.cs.utk.edu:6714"  \
  "tam.ens-lyon.fr:6714" \
  "taranga.metalab.unc.edu:6714" \
  "taylor.cs.utk.edu:6714"  \
  "tunnel.ipv6.upr.edu:6714"  \
  "turkey.cs.wisc.edu:6714" \
  "valnure.cs.ucsb.edu:6714"  \
  "video.ils.unc.edu:6714"  \
  "wyrd.anu.edu.au:6714" ]

        ComboBox $f.combo -editable true -width 35 -textvariable xnd_command(depot) \
                -values $l -background $xnd_command(bgReqColor) 
        pack $f.th_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 
    # ADVANCED FRAME
    set advf [ $advFrame getframe ]
    set nwsOpts [TitleFrame $advf.nwsOpts -text "Data Type" -background $xnd_command(bgAdvColor) ]
    set subf [ $nwsOpts getframe ] 
    set f [frame $subf.type -background $xnd_command(bgAdvColor) ]
        radiobutton $f.geographic -text "Geographic Proximity." \
                -variable xnd_command(res_mode) -background $xnd_command(bgAdvColor) \
                -value "--geo "
        radiobutton $f.nwsresolution -text "NWS Resolution." \
                -variable xnd_command(res_mode) \
                -background $xnd_command(bgAdvColor)  -value "--nws "
        pack $f.geographic -side top -anchor w 
        pack $f.nwsresolution -side top -anchor w 
        pack $f -fill x -side top 

    set nwsSource [TitleFrame $advf.source -text "Source" -background $xnd_command(bgAdvColor) ]
    set subf [ $nwsSource getframe ] 
    set f [frame $subf.source -background $xnd_command(bgAdvColor) ]
        radiobutton $f.local -text "Local Cache." \
                -variable xnd_command(res_source) -background $xnd_command(bgAdvColor) \
                -value "-cache "
        radiobutton $f.lbone -text "LBone Query." \
                -variable xnd_command(res_source) \
                -background $xnd_command(bgAdvColor)  -value "-live "
        pack $f.local -side top -anchor w 
        pack $f.lbone -side top -anchor w 
        pack $f -fill x -side top 

    pack $nwsOpts -side left -fill both -expand yes 
    pack $nwsSource -side left -fill both -expand yes 
    return
}

proc display_preferences { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME 
    set reqf [ $reqFrame getframe ]
    set subf [ frame $reqf.frame -background $xnd_command(bgReqColor) ] 
    set f [frame $subf.lbone -background $xnd_command(bgReqColor) ]
        label $f.lb_lab -text "Lbone Server:"  -background $xnd_command(bgReqColor)
        set l [ list "acre.sinrg.cs.utk.edu" \
                       "galapagos.cs.utk.edu" \
                       "vertex.cs.utk.edu" \
                       "adder.cs.utk.edu" ]
        ComboBox $f.combo -editable true -textvariable xnd_command(lbone_server) \
                -values $l -background $xnd_command(bgReqColor)
        DynamicHelp::register $f.lb_lab balloon $xnd_help(lboneserver)
        DynamicHelp::register $f.combo balloon $xnd_help(lboneserver)
        pack $f.lb_lab -side left -anchor w
        pack $f.combo -side left -anchor e
        pack $f -side top -fill x
#set f [ display_location $subf $xnd_command(bgReqColor) $xnd_help(location) \
#            "Your location:" \
#            xnd_command(local_loc_keyword) xnd_command(local_loc_value) \
#            xnd_command(local_loc_city) ]
    set f [ frame $subf.location -background $xnd_command(bgReqColor) ]
        label $f.loc_lab -text "Your location:" -background $xnd_command(bgReqColor)
        ComboBox $f.combo_value -editable true \
                -textvariable xnd_command(local_loc_value) \
                -width 8 -background $xnd_command(bgReqColor) \
                -helptype balloon -helptext $xnd_help(location)

        set l [list "zip= " "state= " "country= " "airport= " ]
        ComboBox $f.combo_keyword -editable false \
                -textvariable xnd_command(local_loc_keyword) \
                -values $l -width 8 \
                -modifycmd "adjust_location_values $f.combo_value xnd_command(local_loc_keyword) $f.ent_city" \
                -background $xnd_command(bgReqColor) \
                -helptype balloon -helptext $xnd_help(location)

        label $f.loc_city -text "city= " -background $xnd_command(bgReqColor)
        DynamicHelp::register $f.loc_city balloon $xnd_help(location)
        entry $f.ent_city -state normal -textvariable xnd_command(local_loc_city)
        DynamicHelp::register $f.ent_city balloon $xnd_help(loc_city)

        pack $f.loc_lab -side left -anchor w
        pack $f.combo_keyword -side left -anchor e
        pack $f.combo_value -side left -anchor e
        pack $f.loc_city -side left -anchor e
        pack $f.ent_city -side left 
        pack $f -side top -fill x 

#checkbutton $subf.cango -text "allow user to leave this tab." \
#                    -variable xnd_command(cango) -background $xnd_command(bgReqColor)
#    pack $subf.cango -fill both -side top -expand yes 
    pack $subf -side left -fill y 

    # ADVANCED FRAME
    set advf [ $advFrame getframe ] 
    set globalPrefs [TitleFrame $advf.globalPrefs -text "Global Preferences" \
                        -background $xnd_command(bgAdvColor) ]
    set subf [ $globalPrefs getframe ]
#set subf [ frame $advf.frame -background $xnd_command(bgAdvColor) ]
    set f [frame $subf.viz -background $xnd_command(bgAdvColor) ]
        label $f.th_lab -text "Display Host: "  -background $xnd_command(bgAdvColor)
        entry $f.vizentry -width 20 -textvariable xnd_command(vizhost) \
                -background white
        DynamicHelp::register $f.th_lab balloon $xnd_help(vizhost)
        DynamicHelp::register $f.vizentry balloon $xnd_help(vizhost)
        pack $f.th_lab -side left -fill x 
        pack $f.vizentry -side right 
        pack $f -side top -fill x 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x 

    set f [ display_copies $subf $xnd_command(bgAdvColor) $xnd_help(copies) ]
    pack $f -side top -fill x 
#set f [frame $subf.copies -background $xnd_command(bgAdvColor) ]
#        label $f.cop_lab -text "Copies:"  -background $xnd_command(bgAdvColor)
#        DynamicHelp::register $f.cop_lab balloon $xnd_help(copies)
#        set l [ list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15"]
#        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(copies) \
#                -values $l -background $xnd_command(bgAdvColor) \
#                -helptype balloon -helptext $xnd_help(copies)
#        pack $f.cop_lab -side left -fill x 
#        pack $f.combo -side right 
#        pack $f -side top -fill x 
    set f [ display_blocksize $subf $xnd_command(bgAdvColor) $xnd_help(upl_blocksize) ]
    pack $f -side top -fill x 

    set f [frame $subf.intmemory -background $xnd_command(bgAdvColor)]
        label $f.block_lab -text "Internal Memory: " -background $xnd_command(bgAdvColor)
        set l [ list "16M" "32M" "64M" "128M" "256M" "512M" ]
        ComboBox $f.combo -editable true -width 7 -textvariable xnd_command(memory) \
                -values $l -background $xnd_command(bgAdvColor)
        DynamicHelp::register $f.block_lab balloon $xnd_help(memory)
        DynamicHelp::register $f.combo balloon $xnd_help(memory)
        pack $f.block_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 
    set f [frame $subf.timeout -background $xnd_command(bgAdvColor) ]
        label $f.cop_lab -text "Timeout:"  -background $xnd_command(bgAdvColor)
        set l [ list "60" "240" "600" "1200" "2400" ]
        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(timeout) \
                -values $l -background $xnd_command(bgAdvColor)
        DynamicHelp::register $f.cop_lab balloon $xnd_help(timeout)
        DynamicHelp::register $f.combo balloon $xnd_help(timeout)
        pack $f.cop_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 
    set f [ display_duration $subf $xnd_command(bgAdvColor) $xnd_help(duration) ]
    pack $f -side top -fill x 

    set f [ display_alloctype $subf $xnd_command(bgAdvColor) $xnd_help(alloc_type) ]
    pack $f -side top -fill x

    set listPrefs [TitleFrame $advf.listPrefs -text "Other Preferences" \
                        -background $xnd_command(bgAdvColor) ]
    set subf [ $listPrefs getframe ]
    set f [frame $subf.list_physical -background $xnd_command(bgAdvColor) ]
        checkbutton $f.list_physical \
                -text "List the Physical size of mappings\nrather than the logical." \
                -variable xnd_command(list_physical) -background $xnd_command(bgAdvColor) 
        checkbutton $f.adv \
                -text "Show all Advanced settings." \
                -variable xnd_command(adv) -background $xnd_command(bgAdvColor) 
        pack $f.list_physical -anchor w -side top 
        pack $f.adv -anchor w -side top
        pack $f -side top -fill x
    set f [frame $subf.fopen -background $xnd_command(bgAdvColor) ]
        label $f.lab -text "Prefered exNode directory: " \
                -background $xnd_command(bgAdvColor) 
        entry $f.ent -width 25 -textvariable xnd_command(xnddirectory) -background white
        button $f.but -text "Browse.." \
                -command "fileDialog $subf $f.ent open_dir xyz"  \
                -background $xnd_command(bgAdvColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top 
    pack $globalPrefs -side left -fill y 
    pack $listPrefs -side left -fill y 

    return
}

proc display_download { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    global env
    # REQUIRED FRAME 
    set subf [ $reqFrame getframe ]
    set e [frame $subf.fsave  -background $xnd_command(bgReqColor) ]
        label $e.lab -text "Download the file to: " -background $xnd_command(bgReqColor) 
        entry $e.ent -width 45 -textvariable xnd_command(open_regular) -background white
        button $e.but -text "Browse.." -command \
                    "fileDialog $subf $e.ent save_regular $xnd_command(open_regular) \"\"" \
                    -background $xnd_command(bgReqColor) 
        pack $e.lab -side top -anchor w
        pack $e.ent -side left -expand yes -fill x
        pack $e.but -side right 
    set f [frame $subf.fopen -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select an exNode to download: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd)  -background white
        button $f.but -text "Browse.." -command "fileDialog $subf $f.ent open_xnd_download $e.ent" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -anchor w -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes

        pack $e -fill x -side top -expand yes
    # ADVANCED FRAME 
    set advf [ $advFrame getframe ] 
    set workUnit [TitleFrame $advf.workUnit -text "Transaction Size" -background $xnd_command(bgAdvColor) ]
    set subf [ $workUnit getframe ] 
    set f [ display_blocksize $subf $xnd_command(bgAdvColor) $xnd_help(dl_blocksize) ]
    pack $f -side top -fill x 

    set f [frame $subf.cache -background $xnd_command(bgAdvColor) ]
        Label $f.block_lab -text "Cache : " -background $xnd_command(bgAdvColor) \
            -helptype balloon -helptext $xnd_help(cache)
        set l [ list 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 40 50 75 100 ]
        ComboBox $f.combo -editable true -width 7 -textvariable xnd_command(cache) \
                -values $l -background $xnd_command(bgAdvColor) \
                -helptype balloon -helptext $xnd_help(cache)
        pack $f.block_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 
    set f [frame $subf.prebuf -background $xnd_command(bgAdvColor) ]
        Label $f.block_lab -text "Prebuffer : " -background $xnd_command(bgAdvColor) \
            -helptype balloon -helptext $xnd_help(prebuffer)
        set l [ list 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 40 50 75 100 ]
        ComboBox $f.combo -editable true -width 7 -textvariable xnd_command(prebuffer) \
                -values $l -background $xnd_command(bgAdvColor) \
            -helptype balloon -helptext $xnd_help(prebuffer)
        pack $f.block_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 

    set f [ display_offset $subf $xnd_command(bgAdvColor) $xnd_help(man_offset) ]
    pack $f -side top -fill x 
    set f [ display_length $subf $xnd_command(bgAdvColor) $xnd_help(man_length) ]
    pack $f -side top -fill x 

    set progressDrivenRedundance [TitleFrame $advf.pdr -text "Progress Driven Redundance"  -background $xnd_command(bgAdvColor) ]
    set subf [ $progressDrivenRedundance getframe ] 
    set f [frame $subf.progress -background $xnd_command(bgAdvColor) ]
        label $f.th_lab -text "Progress : " -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.th_lab balloon $xnd_help(progress)
        set l [ list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" ]
        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(progress) \
                -values $l -background $xnd_command(bgAdvColor)  \
                -helptype balloon -helptext $xnd_help(progress)

        pack $f.th_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 
    set f [frame $subf.redundance -background $xnd_command(bgAdvColor) ]
        label $f.th_lab -text "Redundance: " -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.th_lab balloon $xnd_help(redundance)
        set l [ list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ]
        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(redundance) \
                -values $l -background $xnd_command(bgAdvColor) \
                -helptype balloon -helptext $xnd_help(redundance)
        pack $f.th_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 
    set f [frame $subf.tpd -background $xnd_command(bgAdvColor) ]
        label $f.th_lab -text "Maximum threads\nper depot: " \
                -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.th_lab balloon $xnd_help(max_threads)
        set l [ list "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ]
        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(tpd) \
                -values $l -background $xnd_command(bgAdvColor) \
                -helptype balloon -helptext $xnd_help(max_threads)
        pack $f.th_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 

    set performance [TitleFrame $advf.perf -text "Performance" \
        -background $xnd_command(bgAdvColor) ]
    set subf [ $performance getframe ] 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x 

    set f [frame $subf.play -background $xnd_command(bgAdvColor) ]
        checkbutton $f.stream -text "Stream content to player." \
                    -variable xnd_command(stream) -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.stream balloon $xnd_help(stream)
        pack $f.stream -side top -fill x
        pack $f -side top -fill x

    pack $workUnit -side left -fill both -expand yes 
    pack $progressDrivenRedundance -side left -fill both -expand yes 
    pack $performance -side left -fill both -expand yes 


}
proc display_copies { subf color help } {
    global xnd_command
    set f [frame $subf.copies -background $color ]
    label $f.cop_lab -text "Copies:"  -background $color
    DynamicHelp::register $f.cop_lab balloon $help
    set l [ list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15"]
    ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(copies) \
            -values $l -background $color \
            -helptype balloon -helptext $help
    pack $f.cop_lab -side left -fill x 
    pack $f.combo -side right 
    return $f
}
proc display_alloctype { subf color help } {
    global xnd_command
    set f [frame $subf.alloc_type -background $color ]
    label $f.aloc_lab -text "Allocation Type: " -background $color
    set l [ list "soft" "hard" ]
    ComboBox $f.combo -editable false -width 6 \
            -textvariable xnd_command(alloc_type) \
            -values $l -background $color \
            -helptype balloon -helptext $help
    DynamicHelp::register $f.aloc_lab balloon $help
    pack $f.aloc_lab -side left -fill x 
    pack $f.combo -side right 
    return $f 
}
proc display_maxdepots { subf color help } { 
    global xnd_command
    set f [ frame $subf.maxdepots  -background $color ]
    label $f.dep_lab -text "Max Depots:"  -background $color
    entry $f.ent -width 6 -textvariable xnd_command(maxdepots)
    DynamicHelp::register $f.dep_lab balloon $help
    DynamicHelp::register $f.ent balloon $help
    pack  $f.dep_lab  -side left -fill x 
    pack  $f.ent -side right
    return $f 
}
proc display_offset { subf color help } { 
    global xnd_command
    set f [ frame $subf.offset -background $color ]
        label $f.dep_lab -text "Offset :"  -background $color
        entry $f.ent -width 9 -textvariable xnd_command(man_offset)
        DynamicHelp::register $f.dep_lab balloon $help
        DynamicHelp::register $f.ent balloon $help
        pack  $f.dep_lab  -side left -fill x 
        pack  $f.ent -side right
    return $f 
}
proc display_length { subf color help } { 
    global xnd_command
    set f [ frame $subf.length -background $color ]
        label $f.dep_lab -text "Length :"  -background $color
        entry $f.ent -width 9 -textvariable xnd_command(man_length)
        DynamicHelp::register $f.dep_lab balloon $help
        DynamicHelp::register $f.ent balloon $help
        pack  $f.dep_lab  -side left -fill x 
        pack  $f.ent -side right
    return $f 
}
proc display_location { subf color help txt lk_var lv_var lc_var }  {
    global xnd_command 
    global xnd_help
    upvar $lv_var l_value
    upvar $lk_var l_keyword
    upvar $lc_var l_city
    set f [ frame $subf.location -background $color ]
    label $f.loc_lab -text $txt -background $color 
    DynamicHelp::register $f.loc_lab balloon $help

    set l [list "37921" "49231" "10010" "84912" "73721" ]
    ComboBox $f.combo_value -editable true -textvariable $lv_var \
            -values $l -width 8 -background $color \
            -helptype balloon -helptext $help
    set l [list "zip= " "state= " "country= " "airport= " ]
    set l_keyword "zip= "
    label $f.loc_city -text "city= " -background $color
    entry $f.ent_city -state disabled -textvariable $lc_var
    DynamicHelp::register $f.loc_city balloon $help
    DynamicHelp::register $f.ent_city balloon $xnd_help(loc_city)
    ComboBox $f.combo_keyword -editable false -textvariable $lk_var \
            -values $l -width 8 \
            -modifycmd "adjust_location_values $f.combo_value $lk_var $f.ent_city" \
            -background $color \
            -helptype balloon -helptext $help

    adjust_location_values $f.combo_value l_keyword $f.ent_city

    pack $f.loc_lab -side left -anchor w
    pack $f.combo_keyword -side left -anchor e
    pack $f.combo_value -side left -anchor e
    pack $f.loc_city -side left -anchor e
    pack $f.ent_city -side left 
    return $f
}
proc display_duration { subf color help } {
    global xnd_command 
    set f [frame $subf.duration -background $color ]
    label $f.dur_lab -text "Duration: " -background $color
    set l [ list 1h 12h 1d 2d 3d 4d 5d ]
    ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(duration) \
        -values $l -background $color -helptype balloon -helptext $help
    DynamicHelp::register $f.dur_lab balloon $help
    pack $f.dur_lab -side left -fill x 
    pack $f.combo -side right 
    return $f
}
proc display_threads { subf color help } {
    global xnd_command
    set f [frame $subf.threads -background $color ]
    label $f.th_lab -text "Threads: " -background $color
    set l [ list "all" "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" \
                 "11" "12" "13" "14" "15" "20" "30" "40" "50" "60" "80" ]
    ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(threads) \
            -values $l -background $color \
            -helptype balloon -helptext $help 
    DynamicHelp::register $f.th_lab balloon $help
    pack $f.th_lab -side left -fill x 
    pack $f.combo -side right 
    return $f
}
proc display_blocksize { subf color help } {
    global xnd_command
    set f [frame $subf.blocksize -background $color ]
    label $f.block_lab -text "Blocksize : " -background $color
    set l [ list "16K" "32K" "64K" "128K" "256K" "512K" \
                  "1024K" "1536K" "2048K" "3072K" "5120K" "8000K" "10000K" ]
    ComboBox $f.combo -editable true -width 7 -textvariable xnd_command(blocksize) \
            -values $l -background $color \
            -helptype balloon -helptext $help
    DynamicHelp::register $f.block_lab balloon $help
    pack $f.block_lab -side left -fill x 
    pack $f.combo -side right 
    return $f
}
proc display_addcopy { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME 
    set subf [ $reqFrame getframe ]
    set f [frame $subf.fopen -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select an exNode file to augment: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd) -background white
        button $f.but -text "Browse.." -command "fileDialog $subf $f.ent open_xnd xyz" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -anchor w -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    set f [frame $subf.fsave -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Save new exNode to: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xndout) -background white
        button $f.but -text "Browse.." -command \
                    "fileDialog $subf $f.ent save_xnd $xnd_command(xnd) $xnd_command(xnd).xnd" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    set f [ display_location $subf $xnd_command(bgReqColor) $xnd_help(location) \
            "Choose location:" \
            xnd_command(aug_loc_keyword) xnd_command(aug_loc_value) \
            xnd_command(aug_loc_city) ]
        pack $f -side top -fill x

    # ADVANCED FRAME 
    set advf [ $advFrame getframe ] 
    set exnodeStructure [TitleFrame $advf.exnodeStructure -text "exNode Structure" \
            -background $xnd_command(bgAdvColor) ]
    set subf [ $exnodeStructure getframe ] 
    set f [ display_copies $subf $xnd_command(bgAdvColor) $xnd_help(copies) ]
    pack $f -side top -fill x 

    set f [ display_blocksize $subf $xnd_command(bgAdvColor) $xnd_help(aug_blocksize) ]
    pack $f -side top -fill x 

    set f [frame $subf.balance -background $xnd_command(bgAdvColor) ]
        checkbutton $f.balance -text "Balance." \
                    -variable xnd_command(balance) -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.balance balloon $xnd_help(balance)
        pack $f.balance -side top -anchor w 
        pack $f -side top -fill x
    set f [frame $subf.newcopy -background $xnd_command(bgAdvColor) ]
        checkbutton $f.newcopy -text "Save only new copy." \
                    -variable xnd_command(newcopy) -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.newcopy balloon $xnd_help(newcopy)
        pack $f.newcopy -side top -anchor w
        pack $f -side top -fill x

    set f [ display_offset $subf $xnd_command(bgAdvColor) $xnd_help(man_offset) ]
    pack $f -side top -fill x 
    set f [ display_length $subf $xnd_command(bgAdvColor) $xnd_help(man_length) ]
    pack $f -side top -fill x 

    set dataCondition [TitleFrame $advf.dataCondition -text "Data Condition" -background $xnd_command(bgAdvColor) ]
    set subf [ $dataCondition getframe ] 

    set f [ display_duration $subf $xnd_command(bgAdvColor) $xnd_help(duration) ]
    pack $f -side top -fill x 

    set f [ display_alloctype $subf $xnd_command(bgAdvColor) $xnd_help(alloc_type) ]
    pack $f -side top -fill x

    set uploadPerf [TitleFrame $advf.uploadPerf -text "Augment Performance" -background $xnd_command(bgAdvColor) ]
    set subf [ $uploadPerf getframe ] 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x

    set f [ display_maxdepots $subf $xnd_command(bgAdvColor) $xnd_help(maxdepots) ]
    pack  $f -side top -fill x

    set f [frame $subf.mcopy -background $xnd_command(bgAdvColor) ]
        checkbutton $f.mcopy -text "Use TCP Datamovers\n(MCOPY)." \
                    -variable xnd_command(mcopy)  -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.mcopy balloon $xnd_help(mcopy)
        pack $f.mcopy -side top -fill x -anchor w
        pack $f -side top -fill x

    set f [frame $advf.fopen_rc -background $xnd_command(bgAdvColor) ]
        label $f.lab -text "DepotList file: " -background $xnd_command(bgAdvColor) 
        entry $f.ent -width 45 -textvariable xnd_command(aug_depot_list_file) -background white
        button $f.but -text "Browse.." \
                    -command "fileDialog $subf $f.ent open_xndrc xyz"  \
                    -background $xnd_command(bgAdvColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side bottom

    pack $exnodeStructure -side left -fill both -expand yes 
    pack $dataCondition -side left -fill both -expand yes 
    pack $uploadPerf -side left -fill both -expand yes 
    return 
}
proc display_refresh { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME 
    set subf [ $reqFrame getframe ]
    set f [frame $subf.fsave -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select an exNode file to refresh: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd) -background white
        button $f.but -text "Browse.." -command \
                    "fileDialog $subf $f.ent open_xnd xyz"  -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    # ADVANCED FRAME 
    set advf [ $advFrame getframe ] 
    set allf [ frame $advf.allf -background $xnd_command(bgAdvColor) ]
    set duration [TitleFrame $allf.dur -text "Duration" -background $xnd_command(bgAdvColor) ]
    set subf [ $duration getframe ] 
    set f [frame $subf.maximize -background $xnd_command(bgAdvColor) ]
        radiobutton $f.max -variable xnd_command(refresh) \
            -text "Maximize duration\nof each allocation" -value "-m" -background $xnd_command(bgAdvColor) 
        pack $f.max -side top -anchor w
        pack $f -side top -fill x 
    set f [frame $subf.extby -background $xnd_command(bgAdvColor) ]
        radiobutton $f.add -variable xnd_command(refresh) \
            -text "Extend duration by: " -value "extby"  -background $xnd_command(bgAdvColor) 
        set l [ list 1h 12h 1d 2d 3d 4d 5d ]
        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(duration) \
                -values $l -background $xnd_command(bgAdvColor) 

        pack $f.add -side left -anchor w
        pack $f.combo -side right -anchor e
        pack $f -side top -fill x 
    set f [frame $subf.extto -background $xnd_command(bgAdvColor) ]
        radiobutton $f.add -variable xnd_command(refresh) \
            -text "Extend duration to: " -value "extto" -background $xnd_command(bgAdvColor) 
        set l [ list 1h 12h 1d 2d 3d 4d 5d ]
        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(duration) \
                -values $l -background $xnd_command(bgAdvColor) 

        pack $f.add -side left -anchor w
        pack $f.combo -side right -anchor e
        pack $f -side top -fill x 


    set performance [TitleFrame $allf.perf -text "Performance" -background $xnd_command(bgAdvColor) ]
    set subf [ $performance getframe ] 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x

    pack $duration -side top -fill both -expand yes -anchor w
    pack $performance -side top -fill both -expand yes -anchor w 
    pack $allf -side left -fill y
    return 
}
proc display_delete { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME 
    set subf [ $reqFrame getframe ]
    set f [frame $subf.fopen -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select an exNode file to clean: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd) -background white
        button $f.but -text "Browse.." -command "fileDialog $subf $f.ent open_xnd xyz" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -anchor w -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    set f [frame $subf.fsave -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Save new exNode to: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xndout) -background white
        button $f.but -text "Browse.." -command \
                    "fileDialog $subf $f.ent save_xnd $xnd_command(xnd) $xnd_command(xnd).xnd" -background $xnd_command(bgReqColor)  
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    # ADVANCED FRAME 
    set advf [ $advFrame getframe ] 
    set trimMappings [TitleFrame $advf.trimmappings -text "Trim mappings" -background $xnd_command(bgAdvColor) ]
    set subf [ $trimMappings getframe ] 
    set f [frame $subf.trim -background $xnd_command(bgAdvColor) ]
        checkbutton $f.trim_dead -text "Trim only unreachable mappings." \
                -variable xnd_command(trim_dead) -background $xnd_command(bgAdvColor) 
        checkbutton $f.trim_destructive -text "Destroy trimmed mappings." \
                -variable xnd_command(trim_destructive) -background $xnd_command(bgAdvColor) 
        $f.trim_dead select
        radiobutton $f.trim_all -variable xnd_command(trim_which) \
                -text "Trim all mappings" -value "all" -background $xnd_command(bgAdvColor) 
        radiobutton $f.trim_specific -variable xnd_command(trim_which) \
                -text "Trim these mappings" -value "-m" -background $xnd_command(bgAdvColor) 
        entry $f.seglist -textvariable xnd_command(segments) -background $xnd_command(bgAdvColor) 

        pack $f.trim_dead -side top -anchor w 
        pack $f.trim_destructive -side top -anchor w 
        pack $f.trim_all -side top -anchor w 
        pack $f.trim_specific -side top -anchor w 
        pack $f.seglist -side top  -fill x 
        pack $f -fill x -side top 

    set performance [TitleFrame $advf.perf -text "Performance" -background $xnd_command(bgAdvColor) ]
    set subf [ $performance getframe ] 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x

    pack $trimMappings -side left -fill both -expand yes 
    pack $performance -side left -fill both -expand yes 
    return 
}
proc display_list { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME 
    set subf [ $reqFrame getframe ]
    set f [frame $subf.fsave  -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select an exNode file to list: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd) -background white
        button $f.but -text "Browse.." -command \
                    "fileDialog $subf $f.ent open_xnd xyz" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    # ADVANCED FRAME 
    set advf [ $advFrame getframe ] 
    set listOpts [TitleFrame $advf.listopt -text "List Options" -background $xnd_command(bgAdvColor) ]
    set subf [ $listOpts getframe ] 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x

    set f [frame $subf.list_physical -background $xnd_command(bgAdvColor) ]
        checkbutton $f.list_physical -text "List the Physical size of mappings." \
                -variable xnd_command(list_physical) -background $xnd_command(bgAdvColor) 
        pack $f.list_physical -anchor w -side top 
        pack $f -side top -fill x
    pack $listOpts -side left -fill y -anchor w 

    return 
}
proc adjust_location_values { combobox name city } {
    global xnd_command
    set zip [list "37921" "49231" "10010" "84912" "73721" ]
    set state [list "TN" "NY" "NC" "CA" "WA" "KS" "IN" ]
    set country [list "US" "NL" "FR" "AU" "GB" "DE" "JP" ]
    set airport [list "DCA" "GVA" "BKK" "TYS" "GRU" "ITH" ]

    upvar $name val
#puts "val: $val"
    switch $val { 
       "zip= " {
            $combobox configure -values $zip
            $city delete 0 end
            $city configure -state disabled
        } 
       "state= " {
            $combobox configure -values $state
            $city configure -state normal
        } 
       "country= " {
            $combobox configure -values $country
            $city configure -state normal
        } 
       "airport= " {
            $combobox configure -values $airport
            $city delete 0 end
            $city configure -state disabled
        } 
    }
    $combobox setvalue first
}

proc display_upload { reqFrame advFrame } {
    global xnd_command 
    global xnd_help
    # REQUIRED FRAME 
    set subf [ $reqFrame getframe ]
    set f [frame $subf.fopen -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Select a file to Upload: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(open_regular) -background white
        button $f.but -text "Browse.." -command "fileDialog $subf $f.ent open_regular xyz" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -anchor w -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
    set f [frame $subf.fsave  -background $xnd_command(bgReqColor) ]
        label $f.lab -text "Save the exNode as: " -background $xnd_command(bgReqColor) 
        entry $f.ent -width 45 -textvariable xnd_command(xnd) -background white
        button $f.but -text "Browse.." -command \
                    "fileDialog $subf $f.ent save_xnd $xnd_command(open_regular) $xnd_command(open_regular).xnd" -background $xnd_command(bgReqColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side top -expand yes
#set xnd_command(upl_loc_keyword) "zip= "
    set f [ display_location $subf $xnd_command(bgReqColor) $xnd_help(location) \
            "Choose location:" \
            xnd_command(upl_loc_keyword) xnd_command(upl_loc_value) \
            xnd_command(upl_loc_city) ]
#set f [ frame $subf.location -background $xnd_command(bgReqColor) ]
#        label $f.loc_lab -text "Choose location:"  -background $xnd_command(bgReqColor) 
#
#        set l [list "37921" "49231" "10010" "84912" "73721" ]
#        ComboBox $f.combo_value -editable true -textvariable xnd_command(upl_loc_value) \
#                -values $l -width 8 -background $xnd_command(bgReqColor) 
#        set l [list "zip= " "state= " "country= " "airport= " ]
#        set xnd_command(upl_loc_keyword) "zip= "
#        ComboBox $f.combo_keyword -editable false -textvariable xnd_command(upl_loc_keyword) \
#                -values $l -width 8 \
#                -modifycmd "adjust_location_values $f.combo_value xnd_command(upl_loc_keyword)" \
#                -background $xnd_command(bgReqColor) 
#        adjust_location_values $f.combo_value xnd_command(upl_loc_keyword)
#
#        pack $f.loc_lab -side left -anchor w
#        pack $f.combo_keyword -side left -anchor e
#        pack $f.combo_value -side left -anchor e
        pack $f -side top -fill x
    # ADVANCED FRAME 
    set advf [ $advFrame getframe ] 
    set exnodeStructure [TitleFrame $advf.exnodeStructure -text "exNode Structure" -background $xnd_command(bgAdvColor) ]
    set subf [ $exnodeStructure getframe ] 
    set f [ display_copies $subf $xnd_command(bgAdvColor) $xnd_help(copies) ]
    pack $f -side top -fill x 
#set f [frame $subf.copies -background $xnd_command(bgAdvColor) ]
#        label $f.cop_lab -text "Copies:" -background $xnd_command(bgAdvColor) 
#        set l [ list "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15"]
#        ComboBox $f.combo -editable true -width 4 -textvariable xnd_command(copies) \
#                -values $l -background $xnd_command(bgAdvColor) 
#        pack $f.cop_lab -side left -fill x 
#        pack $f.combo -side right 
#        pack $f -side top -fill x 
    set f [ display_blocksize $subf $xnd_command(bgAdvColor) $xnd_help(upl_blocksize) ]
    pack $f -side top -fill x 

    set f [frame $subf.e2e_blocksize -background $xnd_command(bgAdvColor)  ]
        label $f.block_lab -text "End-to-End\nBlocksize: " \
                -background $xnd_command(bgAdvColor) 
        DynamicHelp::register $f.block_lab balloon $xnd_help(e2e_blocksize)
        set l [ list "16K" "32K" "64K" "128K" "256K" "512K" \
                      "1024K" "1536K" "2048K" "3072K" "5120K" "8000K" "10000K" ]
        ComboBox $f.combo -editable true -width 7 \
                -textvariable xnd_command(e2e_blocksize) \
                -values $l -background $xnd_command(bgAdvColor)  \
                -helptype balloon -helptext $xnd_help(e2e_blocksize)
        pack $f.block_lab -side left -fill x 
        pack $f.combo -side right 
        pack $f -side top -fill x 


    set dataCondition [TitleFrame $advf.dataCondition -text "Data Condition" -background $xnd_command(bgAdvColor) ]
    set subf [ $dataCondition getframe ] 

    set f [ display_duration $subf $xnd_command(bgAdvColor) $xnd_help(duration) ]
    pack $f -side top -fill x 

    set f [ display_alloctype $subf $xnd_command(bgAdvColor) $xnd_help(alloc_type) ]
    pack $f -side top -fill x

    set f [frame $subf.e2e_condition -background $xnd_command(bgAdvColor) ]
        label $f.dur_lab -text "End-to-End Condition: " \
                    -background $xnd_command(bgAdvColor) 
        checkbutton $f.e2e_compress -text "Compression" \
                    -variable xnd_command(e2e_compress) \
                    -background $xnd_command(bgAdvColor) 
        checkbutton $f.e2e_encrypt -text "AES-Encrypt" \
                    -variable xnd_command(e2e_encrypt) \
                    -background $xnd_command(bgAdvColor) 
        checkbutton $f.e2e_checksum -text "MD5-Checksum" \
                    -variable xnd_command(e2e_checksum) \
                    -background $xnd_command(bgAdvColor) 

        DynamicHelp::register $f.dur_lab balloon $xnd_help(e2e_condition)
        DynamicHelp::register $f.e2e_compress balloon $xnd_help(e2e_condition)
        DynamicHelp::register $f.e2e_encrypt balloon $xnd_help(e2e_condition)
        DynamicHelp::register $f.e2e_checksum balloon $xnd_help(e2e_condition)

        pack $f.dur_lab -side top -anchor w 
        pack $f.e2e_compress -side top -anchor w
        pack $f.e2e_encrypt -side  top -anchor w
        pack $f.e2e_checksum -side top -anchor w
        pack $f -side top -fill x

    set uploadPerf [TitleFrame $advf.uploadPerf -text "Upload Performance" \
            -background $xnd_command(bgAdvColor) ]
    set subf [ $uploadPerf getframe ] 
    set f [ display_threads $subf $xnd_command(bgAdvColor) $xnd_help(threads) ]
    pack $f -side top -fill x

    set f [ display_maxdepots $subf $xnd_command(bgAdvColor) $xnd_help(maxdepots) ]
    pack  $f -side top -fill x

    set f [frame $advf.fopen_rc -background $xnd_command(bgAdvColor) ]
        label $f.lab -text "DepotList file: " -background $xnd_command(bgAdvColor) 
        entry $f.ent -width 45 -textvariable xnd_command(upl_depot_list_file) -background white
        button $f.but -text "Browse.." \
                    -command "fileDialog $subf $f.ent open_xndrc xyz"  \
                    -background $xnd_command(bgAdvColor) 
        pack $f.lab -side top -anchor w
        pack $f.ent -side left -expand yes -fill x
        pack $f.but -side right 
        pack $f -fill x -side bottom
#set f [frame $subf.maxdepots  -background $xnd_command(bgAdvColor) ]
#        label $f.dep_lab -text "Max Depots:"  -background $xnd_command(bgAdvColor) 
#        entry $f.ent -width 6 -textvariable xnd_command(maxdepots)
#        pack  $f.dep_lab  -side left -fill x 
#        pack  $f.ent -side right 
#        pack  $f -side top -fill x
#
    pack $exnodeStructure -side left -fill both -expand yes 
    pack $dataCondition -side left -fill both -expand yes 
    pack $uploadPerf -side left -fill both -expand yes 
    return
}

proc showMessageBox {w icon type msg} {
    set button [tk_messageBox -icon $icon -type $type \
	-title Message -parent $w\
	-message $msg ]
}
proc do_not_go { title } {
    global xnd_command
    if { $xnd_command(cango) == 0 } {
        showMessageBox .window "error" "ok" \
            "Save your preferences before continuing."
    }
    return $xnd_command(cango)
}

proc create_req_opt_frames { notebook title nb2 adv } {
    # add page to notebook.
    if { $nb2 != "x" } {
        set page [ $notebook insert end $title -text $title \
            -leavecmd "do_not_go $title" \
        -raisecmd "toggle_run_label_minor $title xnd_command(minor)" ]
    } else {
        set page [ $notebook insert end $title -text $title \
            -leavecmd "do_not_go $title" \
        -raisecmd "toggle_run_label_major $title xnd_command(minor)" ]
    }

    # add frame to page
    set pageFrame [frame $page.pageFrame ]
    # add TitleFrame for both required and optional section.
    set reqFrame [ TitleFrame $pageFrame.reqFrame -text "Necessary Parameters" -bg cornsilk -ipad 2 ]
    if { $adv == 1 } {
        set advArrow [ ArrowButton $pageFrame.advArrow -arrowrelief raised \
                -type button -width 27 -height 22 ]    
        set advFrame [ TitleFrame $pageFrame.advFrame \
                -text "Optional/Advanced Parameters" \
                -bg grey98 -ipad 2 ]
        $advArrow configure -relief groove \
                -command "toggle_adv $advArrow $notebook $advFrame 1 $nb2"  
    } else { 
        set advFrame ""
    }
    # pack all
    pack $reqFrame -side top -fill both 
    if { $adv == 1 } {
        pack $advArrow -side top -anchor w
        # advFrame is packed (or not) by the toggle_adv command 
        toggle_adv $advArrow $notebook $advFrame 0 "x"
    }

    pack $pageFrame -fill both -expand yes
    return [list $reqFrame $advFrame ]
}

proc toggle_adv { advArrow notebook advFrame update nb2 } {
    global xnd_command
    if { $update == 0 } { set xnd_command($advArrow) $xnd_command(adv) }

    if { $xnd_command($advArrow) == 1 } {
        $advArrow configure -dir top
        pack $advFrame -side top -fill both -expand yes 
        $notebook compute_size
        set xnd_command($advArrow) 0
    } else {
        $advArrow configure -dir bottom
        pack forget $advFrame
        $notebook compute_size
        set xnd_command($advArrow) 1 
    }
    if { $nb2 != "x" } { $nb2 compute_size }
}

proc toggle_run_label_major { page var2 } {
    global xnd_command
    upvar $var2 minorPage
    if { $page == "Other" } {
        if { $minorPage == "Preferences" } {
            $xnd_command(exec_button) configure -text "Save"
        } elseif { $minorPage == "DepotList" } {
            $xnd_command(exec_button) configure -text "Save DepotList"
        } else {
            $xnd_command(exec_button) configure -text "$minorPage Now"
        }
    } else {
        $xnd_command(exec_button) configure -text "$page Now"
    }
}
proc toggle_run_label_minor { page var2 } {
    global xnd_command
    upvar $var2 minorPage

    set minorPage $page
    if { $page == "Preferences" } {
        $xnd_command(exec_button) configure -text "Save"
    } elseif { $page == "DepotList" } {
        $xnd_command(exec_button) configure -text "Save DepotList"
    } else {
        $xnd_command(exec_button) configure -text "$page Now"
    }
}


  global xnd_command
  global xnd_help
  global argc
  global argv
  set xnd_command(adv) 0
  set xnd_command(first_tab) "Preferences"

  if { $argc >= 1 } {
    if { [ file exists [ lindex $argv 0 ] ] } {
        # if it ends with an .xnd or not do something different
        set xnd_command(xnd) [ lindex $argv 0 ]
        set xnd_command(first_tab) "Download"
    } 
  }

  for {set i 0} {$i < $argc} {incr i} \
  {
    set arg1 [ lindex $argv $i ]
    if { $arg1 == "-advanced" } { 
       set xnd_command(adv) 1
    } 
    if { $arg1 == "-tab" } {
        set xnd_command(first_tab) [ lindex $argv [expr $i+1] ]
    }
  }

  set xnd_command(subgo) 0
  set xnd_command(othersub) 1 
  set xnd_command(vizconfig)  "USA"
  set xnd_command(lbone_server)  "acre.sinrg.cs.utk.edu"
  set xnd_command(vizhost)  "localhost"
  set xnd_command(minor) "Preferences"
  set xnd_command(bgAdvColor) grey98
  set xnd_command(bgReqColor) cornsilk
  set xnd_command(timeout) 1200
  set xnd_command(memory) "32M"
  set xnd_command(progress_var) -1
  set xnd_command(bg_color) grey80
  set xnd_command(mode) play
  set xnd_command(copies) 1
  set xnd_command(blocksize) "5M"
  set xnd_command(e2e_blocksize) "512K" 
  set xnd_command(duration) "1d"
  set xnd_command(alloc_type) "soft"
  set xnd_command(e2e_encrypt) 0
  set xnd_command(e2e_checksum) 1
  set xnd_command(threads) 8
  set xnd_command(maxdepots) 5
  set xnd_command(helptip_delay) 299

  set xnd_command(cache) 1
  set xnd_command(prebuffer) 1
  set xnd_command(progress) 1
  set xnd_command(redundance) 1
  set xnd_command(tpd) 0
  set xnd_command(refresh) "extby"
  set xnd_command(helptip_on) 1
  set xnd_command(depot_type) "DEPOT"
  set xnd_command(xnddirectory) $env(HOME)

  set env(LOCAL_OS) [exec perl -e "print $^O"]
  puts "local os $env(LOCAL_OS)"

  init_defaults 
  init_help
  init_all

