#!/usr/bin/wish


proc plot_depot { i can } \
{
  global name
  global xc
  global xr
  global xl
  global xw
  global yt
  global yb
  global yh
  global yc
  global color

  # depot oval
  $can create oval $xl($i) $yt($i) $xr($i) $yb($i) -fill $color($i) -tag depot
  $can lower depot d
}
  
proc plot_string { i can } \
{
    global strings
    global fontcolor
    global config

    set l $strings($i)
    if { $config("shownames") > 0 || [ lindex $l 3 ] > 0 } \
    {
        if { [ string length [ lindex $l 0 ] ] < 4 } { 
            set thename [ string toupper [ lindex $l 0 ] 0 end ]
        } else { 
            set thename [ string toupper [ lindex $l 0 ] 0 0 ]
        }
        $can create text [ lindex $l 1 ] [ lindex $l 2 ] \
         -text $thename -fill $fontcolor -font {Helvetica 10 bold } -anchor e
    }
}


proc on_map { lat lon } {
    global config

    set lat1 $config("lat1")
    set lat2 $config("lat2")
    set lon1 $config("lon1")
    set lon2 $config("lon2")
    ##puts "$lat1 $lat2 $lat $lon1 $lon2 $lon"

    if { $lon < $lon1 || \
         $lon > $lon2 || \
         $lat > $lat1 || \
         $lat < $lat2 } {
         return 0
    }
    return 1
}
  

proc read_depots { dfile } {

  global indices
  global config
  global port
  global color
  global host
  global name
  global xc
  global xr
  global xl
  global xw
  global yt
  global yb
  global yh
  global yc
  global rows
  global cols
  global ndepots
  global strings
  global nstrings
  global depots_list
  global ALTERNATE_list
  global STRING_list
  global depot_group_list
  global glon
  global glat

  set w [ image width us ]
  set h [ image height us ]
  set h [ expr $h ] 
  if { [ info exists config("lat1") ] } \
  {
      set lat1 $config("lat1")
      set lat2 $config("lat2")
      set lon1 $config("lon1")
      set lon2 $config("lon2")
  }

  set ALTERNATE_list [ list \
        {ALTERNATE blue:6714 quidam.ucsd.edu:6714} \
    ]

  # HACK : adjust x position 08/16/02
  set tcl_precesion 17

  set dp_size $config("depotsize")
  set dp_size_y [ expr $dp_size *0.73]

  set i 1
  set color(0) "black"
  set ns 0
  set out_cnt_lat 1
  set out_cnt_lon 1
  set cur_lat 0
  set cur_lon 0
  set   off_map 0

  foreach group [array names depot_group_list ] \
  {
      set l [ split $group ':' ]
      set gname  [ lindex $l 0 ]
##puts "GROUP == $gname" 
      set ylat   [ lindex $l 1 ] 
      set xlon   [ lindex $l 2 ] 
      set xcoord [ lindex $l 3 ]
      set ycoord [ lindex $l 4 ]
      set j 4
      set off_map 0
      if { $ylat == -1 || $xlon == -1 } { 
          set X [ expr ($xcoord * $w)/$cols ]
          set Y [ expr ($ycoord * $h)/$rows - ($j*3)]
          # #puts "X: $X Y: $Y"
      } else {
          if { ! [ on_map $ylat $xlon ] } \
          {
             if { !$config(hideoff) || $gname == "Other" } \
             {
                set off_map 1
                set dlat [ expr ($lat1-$lat2) / 10.0 ]
                set dlon [ expr ($lon2-$lon1) / 20.0 ]

##puts "$dlat $lat2 $cur_lat $out_cnt_lat $out_cnt_lon"
                if { $cur_lat > [ expr $lat2+$dlat*8 ] } {
                  # #puts "++++Cur_Lat > $lat2 + dlat*8"
                  set out_cnt_lat 1
                  incr out_cnt_lon
                }
                set cur_lat [ expr $lat2 + $dlat*$out_cnt_lat ]
                incr out_cnt_lat
                set xlon [ expr $lon2 - $dlon*$out_cnt_lon ]

                set X [ expr { (($xlon - $lon1 ) / ($lon2 - $lon1)) * $w } ]
                set Y [ expr { (($cur_lat - $lat1) / ($lat2 - $lat1)) * $h } ]
                set ylat $cur_lat
             } else {
                set X -1
                set Y -1
             }
          } else {
              set X [ expr { (($xlon - $lon1 ) / ($lon2 - $lon1)) * $w } ]
              set Y [ expr { (($ylat - $lat1) / ($lat2 - $lat1)) * $h } ]
          }
      }
      if { $gname != ""} \
      {
          set x $xcoord
          set y $ycoord

          if { $X != -1 } {
              set strings($ns) [ list $gname $X [expr $Y + 4 ] $off_map ]
              set ns [ expr $ns + 1 ] 
          }
      }

      foreach depot $depot_group_list($group) \
      {
        if { $X != -1 } {
          set name($i) [lindex $depot 0]
          set host($i) [lindex $depot 1]
          set port($i) [lindex $depot 2]
          set color($i) [lindex $depot 3]

        # Translate grid coordinates into pixel coordiates.
          #set x [ expr ($xcoord * $w)/$cols ]
          #set y [ expr ($ycoord * $h)/$rows - ($j*5)]
          set x  $X
          set y  [ expr $Y - ($j*2) ]

          set glat($i) $ylat
          set glon($i) $xlon
        # X  
          set xl($i) [ expr $x - ($dp_size/2)]
          set xr($i) [ expr $x + ($dp_size/2)]
          set xw($i) [ expr ($xr($i) - $xl($i)) ] 
          set xc($i) [ expr ($xl($i)+$xr($i))/2.0 ]
      

        # Y 
          set yt($i) [ expr $y - ($dp_size_y)/2]
          set yb($i) [ expr $y + ($dp_size_y)/2]
          set yh($i) [ expr ($yb($i) - $yt($i)) ] 
          set yc($i) [ expr ($yt($i)+$yb($i))/2.0 ]
  
          ##puts "$host($i):$port($i)"
          set key "$host($i):$port($i)"
            # #puts "key == $key"
          set char "X"
          set indices($key) $i

          set j [ expr $j + 1 ] 
          set i [ expr $i + 1 ] 
        }
      }
  }
#  foreach alternate $ALTERNATE_list \
#  {
#      scan $alternate "%s %s %s" dummy key1 key2
#      set indices($key1) $indices($key2)
#  }
  set ndepots $i
  set nstrings $ns

}

proc round_to { val mult } {
    set x [ expr { $val / $mult } ]
    set x [ expr { int($x) +1 } ]
    set x [ expr { $x * $mult } ]
}

# determine if the group name is off the map or not. 
# if it is off the map, 
#       then we can print it with the depot. 
# if it is on the map, 
#       then we can draw a line to it, and avoid it.
#
# now position as close to the depot as possible. either along the left, top
# or bottom.
#
# to do this, we have 'height'/12 positions on the left, 'width'/80 positions
# on the top and bottom.  
#
# To test location, we can translate directly from lat or lon to the nearest
# available location on the top bottom and left.  Which ever of these three
# positions are closest win.
# There could be as many as 6 tests + 3 more to compare between
# top/bottom/left.  It is possible to keep an 'array' of used positions for
# each location.
#
# this sucks, so perhaps if we sorted the groups by lat then drew arrows in
# order to minimize criss cross.
#
proc draw_names { } {
    global strings
    global config
    global fontcolor
    global nstrings
    global xc 
    global yc 

    set X 80
    set Y 5

    for { set i 1 } { $i < $nstrings } { incr i } {

        set l $strings($i)
        if { [ lindex $l 3 ] == 0 } {
            if { [ string length [ lindex $l 0 ] ] < 4 } { 
                set thename [ string toupper [ lindex $l 0 ] 0 end ]
            } else { 
                set thename [ string toupper [ lindex $l 0 ] 0 0 ]
            }
            # lat - left
            set lat [ round_to  [lindex $l 2] 12.0 ]
# left
            if { [ info exist p1($lat) ] } {
                set d1 [ find_next_closest p1 [lindex $l 1] [lindex $l 2] 1 ]
            } else {
                set dist [lindex $l 2]
                set d1 [ list $lat $dist ]
            }
# top
# bottom
            set lon [ round_to [lindex $l 1] 80.0 ]
            if { [ info exist p2($lon) ] } {
                set d2 [ find_next_closest p2 [ lindex $l 1] [ lindex $l 2] 0 ]
            } else {
                set dist [ expr 390 - [lindex $l 1] ]
                set d2 [ list $lon $dist ]
            }
##puts "d1: $d1 d2: $d2"
            if { [lindex $d1 1] < [lindex $d2 1]} {
# left
                set p1([lindex $d1 0]) 1
                .mv.c create text 80 [lindex $d1 0] -text $thename \
                    -fill $fontcolor -font {Helvetica 9 bold } -anchor e
                .mv.c create line 85 [lindex $d1 0] [lindex $l 1] \
                    [expr [lindex $l 2] - 10] -fill $fontcolor -tag name_arrow 
            } else {
# top
                set p2([lindex $d2 0]) 1
                .mv.c create text [lindex $d2 0] 390 -text $thename \
                    -fill $fontcolor -font {Helvetica 9 bold } -anchor s
                .mv.c create line [lindex $d2 0] 390 \
                     [lindex $l 1] [expr [lindex $l 2] - 10] \
                    -fill $fontcolor -tag name_arrow 
            }

            # draw name
#.mv.c create text $X $Y -text $thename \
#                -fill $fontcolor -font {Helvetica 12 bold } -anchor e
             # draw line to group
#            .mv.c create line [expr $X+5] $Y [lindex $l 1] [ expr [lindex $l 2] - 10] \
#                -fill $fontcolor -tag name_arrow 
#            set Y [ expr $Y + 11 ]
        }
    }
}


# latitude and longitude are really x/y coords
proc find_next_closest { coords lat lon left } {
    if { $left } { 
        set pos [ round_to $lat 12.0 ]
        set c $pos
        while { [ info exists coords($pos)] } \
        { 
            set pos [ expr $pos + 12.0 ]
        }
        set open_up $pos
        set pos $c
        while { [ info exists coords($pos)] } \
        { 
            set c [ expr $pos - 12.0 ]
        }
        set open_down $pos
        # compare the distance between open_up and open_down 
        set p1 [ expr { sqrt( pow($lon,2) + pow(($open_up-$lat), 2)) } ]
        set p2 [ expr { sqrt( pow($lon,2) + pow(($open_down-$lat), 2)) } ]
        if { $p1 < $p2 } {
            return [ list $open_up $p1 ]
        } else {
            return [ list $open_down $p2 ]
        }
    } else { 
        set pos [ round_to $lon 80.0 ] 
        set c $pos
        while { [ info exists coords($pos) ] } {
            set pos [ expr $pos + 80.0 ]
        }
        set open_right $pos
        set pos $c
        while { [ info exists coords($pos) ] } {
            set pos [ expr $pos - 80.0 ]
        }
        set open_left $pos
        # compare the two possible distances.
        set p1 [ expr { sqrt( pow(400-$lat,2) + pow(($open_left-$lon), 2)) } ]
        set p2 [ expr { sqrt( pow(400-$lat,2) + pow(($open_right-$lon), 2)) } ]
        if { $p1 < $p2 } {
            return [ list $open_left $p1 ]
        } else {
            return [ list $open_right $p2 ]
        }
    }
}

proc draw_depots { } {
  global ndepots
  global nstrings
  global arrow_width

  set width [ image width us ]
  set height [ image height us ]
  set height [ expr $height ]

# create a stacking context to which Arrows Mappinbs and borders can be
# 'raise'd or 'lower'd
  .mv.c create line 0 0 1 1 -fill black -tag e
  .mv.c create line 0 0 1 1 -fill black -tag d
  .mv.c create line 0 0 1 1 -fill black -tag c
  .mv.c create line 0 0 1 1 -fill black -tag b
  .mv.c create line 0 0 1 1 -fill black -tag a

  .mv.c create image 0 0 -image us -anchor nw -tag mooshoo
  .mv.c lower mooshoo e
  .mv.c create line 0 $height $width $height -width 3 -fill red

  for {set i 1} {$i < $ndepots} {incr i} {
    plot_depot $i .mv.c
  }

  for {set i 0} {$i < $nstrings} {incr i} {
    plot_string $i .mv.c
  }

}

proc draw_grid { } {
    global cols
    global rows
    set width [ image width us ]
    set height [ image height us ]
    set xc [ expr $width / $cols ]
    set yr [ expr $height / $rows ]
    for { set i 0 } { $i <= $cols } { incr i} {
        .mv.c create line [ expr $i * $xc] 0 [expr $i*$xc] $height -fill gray50
        .mv.c create text [ expr $i * $xc] 10 -fill white -text $i
        .mv.c create text [ expr $i * $xc] [expr $height - 10 ] -fill white -text $i
    }
    for { set j 0 } { $j <= $rows} { incr j} {
        .mv.c create line 0 [expr $j * $yr] $width [expr $j*$yr] -fill gray50
        .mv.c create text 10 [expr $j * $yr] -fill white -text $j
        .mv.c create text [expr $width - 10] [expr $j * $yr] -fill white -text $j
    }

}


proc redraw { } {
  clear
  draw_depots

  display_exnode
}
  
  
proc clear_exnode { } {
  global config 

  # reset to zero connections.  useful for tcl errors
  set config(connections) 0
  .mv.buttons.status configure -text "$config(connections) Active Connection(s)"

  new_exnode "" "" -1 
  redraw
}

proc clear { } {
  garbage_collect
}

proc new_exnode {fname orig size } {
  global exnode
  global extray

# #puts "entering new_exnode $orig $size"
  set exnode("cols") 0
  set exnode("size") $size
  set exnode("fname") $fname
  set exnode("orig") $orig
  set exnode("arrows") 0

  set exnode("animdelay") 300

  set width [ image width us ]
  set height [ image height us ]
  set height [ expr $height ]

        # Text beginning (upper left)
  set exnode("xtbegin") 5          
  set exnode("ytbegin") [ expr $height + 5 ]

                                   # Exnode display stuff
  set exnode("xincr") [ expr $width / 14 ]
  set exnode("yincr") [ expr $extray / 12 ]
  set exnode("ytop") [ expr $height + $exnode("yincr") * 2 ]
  set exnode("ybot") [ expr $height + $exnode("yincr") * 11.5 ]
  set exnode("yheight") [ expr $exnode("ybot") - $exnode("ytop") ]
  set exnode("xleft") [ expr $exnode("xincr") * 3]

}

proc open_socket {} {
  global exnode
  global config

  set blue [socket -server Server_Accept $config("port")]
    .mv.c delete "awaitConnect"
    .mv.c create text 10 [ expr $config("height") - 10 ] -anchor w \
          -text "Awaiting Connection.." \
          -justify left -tag "awaitConnect" \
          -fill white -font {Helvetica 16 bold }

  #set exnode("filename") "SOCKET"
  #set exnode("filedesc") $gf
  # .mv.buttons.socket configure -text "Close Socket" -command close_socket 
  
  #fileevent $gf readable dispatch
}
proc Server_Accept {sock addr port} \
{
    global exnode
    global config 

    # BLOCK other incoming connections until the working activity is complete.
    if { ($config(connections) > 0) && \
         ($config("block") == 1) } {
        close $sock
        return
    }

    set exnode("filename") "SOCKET"
    set exnode("filedesc") $sock
    puts $sock "exNode Visualization 0.5"; flush $sock

    # configure  for line operations
    #fconfigure $sock -buffering line
##puts "NEW CONNECTION"
    draw_depots
    fileevent $sock readable [ list new_dispatch $sock ]
    incr config(connections)
    .mv.buttons.status configure -text "$config(connections) Active Connection(s)"
}

proc read_file {} {
  global exnode

  set f $exnode("filename")
  set gf $exnode("filedesc") 

  if { $exnode("filename") == "SOCKET" } {
    set exnode("savefile") $f
    set exnode("savedesc") $gf
  } else {
    set exnode("savefile") "NULL"
    set exnode("savedesc") "NULL"
  }

  set f  [tk_getOpenFile -title "Open File"]
  if { $f == "" } return

  if { [ catch { set gf [ open $f r ] } ] } {
    tk_dialog .mv.error "Open file error" "Can't open file $f" \
              {}  0  "OK"
    return
  }

  set exnode("filename") $f
  set exnode("filedesc") $gf

  dispatch 
}

proc new_dispatch { sock } \
{
    global exnode
    global config

    set f $exnode("filename")

    if { [eof $sock] || [ catch {gets $sock line} ] } \
    { 
        #puts "EOF or other GETS error"
        close_sock $sock
        return
    }

    if { $line == "" } { 
        return
    }
##puts "LINE $line"
    set l [ next_token $line ]
    set command   [lindex $l 0]
    set directive [lindex $l 1]

##puts "COMMAND $command"
    switch $command \
    {
        QUIT
        {
            puts "quitting."
            exit
        }
        TITLE  
        {
##puts "DIRECTIVE $directive"
            handle_message 0 "$directive"
        }
        MESSAGE
        {
            set l [ next_token $directive ]
            handle_message [lindex $l 0] [lindex $l 1]
        }
        SIZE
        {
##puts "DIRECTIVE $directive"
            clear
            handle_message 0.5 "Size $directive"
            handle_resize $directive
            draw_depots
        }
        NWS
        {
            set l [ next_token $directive ]
            handle_nws [ lindex $l 0 ] [ lindex $l 1 ]
        }
        DRAW
        {
            set l [ next_token $directive ]
            handle_draw [lindex $l 0] [lindex $l 1]
        }
        DELETE
        {
            set l [ next_token $directive ]
            handle_delete [lindex $l 0] [lindex $l 1]
        }
        CLEAR
        {
            clear
            draw_depots
        }
    }

}

proc next_token { line } \
{
    set ret [scan $line {%s %[0-9\ -\(\)\~\/_a-zA-Z\:\.]} token remaining ] 
    if { $ret == 1 } \
    {
        set remaining ""
    } else {
        if { $ret != 2 } \
        {
            set token ""
            set remaining ""
        }
    }
    return [ list $token $remaining ]
}

# POS should be 0, 1, 2, 3 no other.
proc handle_message { pos text_message } \
{
    global exnode
    global config

    set ybegin [ expr $config("height") + 5 + ($config("extray")/4.0)*$pos]
    set xbegin 5
#set exnode("upfilename") text_message
    .mv.c delete "pos$pos"
    .mv.c create text $xbegin $ybegin -anchor nw \
          -text $text_message \
          -justify left -tag "pos$pos" \
          -fill white -font {Helvetica 16 bold }
}

proc handle_nws { which what } \
{
    global config
    global color_scale

    # ##puts "NWS: which: $which what: $what"
    switch $which \
    {
        Arrow
        {
            if { [scan $what {%s %s %s %s} keySrc capID keyDst mbps ] < 4 } \
            {
                # miss formatting
                return 
            } else { 
                # #puts "mbpsBefore: $mbps"
                if { $mbps > $config("nwsMax") } \
                {
                    set mbps $config("nwsMax")
                }
                if { $mbps < $config("nwsMin") } \
                {
                    set mbps $config("nwsMin")
                }
                # #puts "mbpsAfter: $mbps"
                set i [ expr ($mbps - $config("nwsMin"))/ $config("nwsSpan") ]
                set j [ expr int($i)]
                # #puts "j: $j"
                if { $j >= $config("scalecnt") } { 
                    set j [ expr $config("scalecnt") - 1 ] 
                }
                handle_arrow3_display $keySrc $keyDst $capID $j ""
            }
        }
        SCALE 
        {
            if { [scan $what {%s %s} xMin xMax ] < 2 } {
##puts "scan failed for min/max"
                return
            } else {
                ##puts "SCale: min: $xMin max: $xMax"
                set config("nwsMin") $xMin
                set config("nwsMax") $xMax

                set range [ expr $xMax - $xMin ]
                set cnt  [ expr $config("scalecnt") +0.0]
                set span [ expr $range / $cnt ]

                set config("nwsSpan") $span
                set index $xMin
                set i 0
                while { $index < $xMax && $i < $config("scalecnt")} \
                {
                    # draw box from index to index+range 
                    handle_nwsScale_display $xMin $xMax $index $span $color_scale($i)
                    set i [ expr $i + 1 ]
                    set index [ expr $index + $span]
                }
            }

        }
    }
}

proc handle_delete { what how } \
{
    global exnode
    global config
    global indices

##puts "What delete -- $what"
    switch $what \
    {
        Mapping
        {
            if { [ scan $how {%s %s %s %s} id offset length key ] < 4 } \
            {
##puts "format error for Delete Mapping; ignoring"
                return
            }
            set l [ locate_colum_id $id $offset $length $key ]
            if { [lindex $l 0] != -1 } \
            {
##puts "DELETING EVERYTHING_____________________!!!"
                handle_mapping_delete [lindex $l 0] [lindex $l 1]
            } else {
##puts "COULD NOT FIND requested mapping to trim."
            }
        }
        Arrow1
        {
# upload
            if { [ scan $how {%s %s %s %s %s} \
                              dummy id offset length keySrc ] < 5} \
            {
                # format error .. ignore it.
##puts "format error for Delete Arrow1; ignoring"
                return
            }
            handle_arrow1_delete $id $offset $length $keySrc
        }
        Arrow2
        {
# download
            if { [ scan $how {%s %s %s %s} \
                              dummy key offset length ] < 4} \
            {
                # format error .. ignore it.
##puts "format error for Delete Arrow2; ignoring"
                return
            }
            handle_arrow2_delete $key $offset $length
        }
        Arrow3
        {
# copy
            if { [ scan $how {%s %s %s %s %s} \
                              dummy keySrc id dummy keyDst ] < 5} \
            {
                # format error .. ignore it.
                #puts "format error for Arrow3; ignoring"
                return
            }
            #puts "keySrc: $keySrc"
            #puts "id: $id"
            #puts "keyDst: $keyDst"
            handle_arrow3_delete $keySrc $keyDst $id
        }
    }
}

proc handle_draw  { what how } {
    global exnode
    global config
    global indices

    #puts "What draw -- $what"
    switch $what \
    {
        MappingBegin
        {
            if { [ scan $how "%s %s %s %s %s" keySrc id offset length keyDst ] < 5 } \
            {
                # format error. best to ignore it.
                return
            } else {
                set exnode("lastoffset") $offset
                set exnode("lastsize")   $length
                if { [info exists indices($keyDst) ] } \
                {
                    set l [ add_exnode_chunk $indices($keyDst) $length $offset 1 $id ]
                } else {
                    set l [ add_exnode_chunk $indices(unknown:1) $length $offset 1 $id ]
                }
                handle_begin_display [lindex $l 0] [lindex $l 1] $keySrc
            }

        }
        MappingAllocate
        {
            if { [ scan $how "%s %s %s %s" id offset length keyDst ] < 4 } \
            {
                # format error. best to ignore it.
                return
            } else {
                set exnode("lastoffset") $offset
                set exnode("lastsize")   $length
                if { [info exists indices($keyDst) ] } \
                {
                    set l [ add_exnode_chunk $indices($keyDst) $length $offset 1 $id ]
                } else {
                    set l [ add_exnode_chunk $indices(unknown:1) $length $offset 1 $id ]
                }
                handle_allocation_display [lindex $l 0] [lindex $l 1]
            }
        }
        MappingFrom
        {
            if { [ scan $how "%s %s %s %s %s %s %s" keySrc s_offset s_length \
                                            id offset length keyDst ] < 7 } \
            {
                # format error. best to ignore it.
                return
            } else {
                set exnode("lastoffset") $offset
                set exnode("lastsize")   $length

                set l [ locate_colum_id $id $offset $length $keyDst ]
                if { [lindex $l 0] != -1 } \
                {
                    #  It is already displayed in the exnode.
                    handle_from_display [lindex $l 0] [lindex $l 1] $keySrc $s_offset $s_length
                } else {
                    #  It must be created.
                    if { [info exists indices($keyDst) ] } \
                    {
                        set l [ add_exnode_chunk $indices($keyDst) $length $offset 1 $id ]
                    } else {
                        set l [ add_exnode_chunk $indices(unknown:1) $length $offset 1 $id ]
                    }
                    handle_allocation_display [lindex $l 0] [lindex $l 1]
                    handle_from_display [lindex $l 0] [lindex $l 1] $keySrc $s_offset $s_length
                }
            }

        }
        MappingFinish
        {
            if { [ scan $how "%s %s %s %s %s %s" s_offset s_length \
                                            id offset length keyDst ] < 6 } \
            {
                # format error. best to ignore it.
                return
            } 
            if { ![info exists disp_text] } \
            {
                set disp_text ""
            }

            # LOOK up location of this id/offset/length/key combo
            set l [ locate_colum_id $id $offset $length $keyDst ]
            if { [lindex $l 0] != -1 } \
            {
                #  It is already displayed in the exnode.
                handle_mapping2_display [lindex $l 0] [lindex $l 1] $s_offset $s_length $disp_text
            } else {
                #  It must be created.
                if { [info exists indices($keyDst) ] } \
                {
                    set l [ add_exnode_chunk $indices($keyDst) $length $offset 1 $id ]
                } else {
                    set l [ add_exnode_chunk $indices(unknown:1) $length $offset 1 $id ]
                }
                handle_mapping2_display [lindex $l 0] [lindex $l 1] $s_offset $s_length $disp_text
            }

        }
        MappingEnd
        {
            if { [ scan $how {%s %s %s %s %[0-9\ -\(\)\~\/_a-zA-Z\:\.]} \
                              id offset length key disp_text ] < 4} \
            {
                # format error .. ignore it.
                return
            }
            if { ![info exists disp_text] } \
            {
                set disp_text ""
            }

            # LOOK up location of this id/offset/length/key combo
            set l [ locate_colum_id $id $offset $length $key ]
            if { [lindex $l 0] != -1 } \
            {
                #  It is already displayed in the exnode.
                handle_mapping2_display [lindex $l 0] [lindex $l 1] $offset $length $disp_text
            } else {
                #  It must be created.
                if { [info exists indices($key) ] } \
                {
                    set l [ add_exnode_chunk $indices($key) $length $offset 1 $id ]
                } else {
                    set l [ add_exnode_chunk $indices(unknown:1) $length $offset 1 $id ]
                }
                handle_mapping2_display [lindex $l 0] [lindex $l 1] $offset $length $disp_text
            }
            # call handle_mapping_display..
        }
        Mapping
        {
            if { [ scan $how {%s %s %s %s %[0-9\ -\(\)\~\/_a-zA-Z\:\.]} \
                              id offset length key disp_text ] < 4} \
            {
                # format error .. ignore it.
                return
            }
            if { ![info exists disp_text] } \
            {
                set disp_text ""
            }

            # LOOK up location of this id/offset/length/key combo
            set l [ locate_colum_id $id $offset $length $key ]
            if { [lindex $l 0] != -1 } \
            {
                #  It is already displayed in the exnode.
                handle_allocation_display [lindex $l 0] [lindex $l 1]
                handle_from_display [lindex $l 0] [lindex $l 1] $key $offset $length
                handle_mapping2_display [lindex $l 0] [lindex $l 1] $offset $length $disp_text
            } else {
                #  It must be created.
                if { [ info exists indices($key) ] } \
                {
                    set l [ add_exnode_chunk $indices($key) $length \
                                             $offset 1 $id ]
                } else {
                    set l [ add_exnode_chunk $indices(unknown:1) $length \
                                             $offset 1 $id ]
                }
                handle_allocation_display [lindex $l 0] [lindex $l 1]
                handle_from_display [lindex $l 0] [lindex $l 1] $key $offset $length
                handle_mapping2_display [lindex $l 0] [lindex $l 1] $offset $length $disp_text
            }

        }
        Arrow1
        {
            if { [ scan $how {%s %s %s %s %s} \
                              dummy id offset length keySrc ] < 5} \
            {
                # format error .. ignore it.
                #puts "format error for Arrow1; ignoring"
                return
            }
            # Look up location of this combo..
            set l [ locate_colum_id $id $offset $length $keySrc ]
            handle_arrow1_display [lindex $l 0] [lindex $l 1] $keySrc
        }
        Arrow2
        {
            if { [ scan $how {%s %s %s %s} \
                              dummy key offset length ] < 4} \
            {
                # format error .. ignore it.
                #puts "format error for Arrow2; ignoring"
                return
            }
            # Look up location of this combo..
#set l [ locate_colum_id $id $offset $length $keySrc ]
            handle_arrow2_display $key $offset $length
        }
        Arrow3
        {
            if { [ scan $how {%s %s %s %s %s %s %[0-9\ -\(\)\~\/_a-zA-Z\:\.]} \
                              dummy keySrc id dummy keyDst level msg ] < 5} \
            {
                # format error .. ignore it.
                #puts "format error for Arrow3; ignoring"
                return
            }
            if { ![info exists msg] } {
                set msg ""
            }
            if { ![info exists level] } {
                set level 0
            }
            ##puts "MESSAGE: $msg"
            handle_arrow3_display $keySrc $keyDst $id $level $msg
        }
        DLBuffer
        {
            if { [ scan $how {%s %s} \
                              offset length ] < 2} \
            {
                # format error .. ignore it.
                #puts "format error for dlbuffer; ignoring"
                return
            }
            set key "unknown:1"
            handle_dlbuffer_display $key $offset $length
        }
        DLSlice
        {
            if { [ scan $how {%s %s %s} \
                              key offset length ] < 3} \
            {
                # format error .. ignore it.
                #puts "format error for dlslice; ignoring"
                return
            }
            handle_dlslice_display $key $offset $length
        }
        Output
        {
            if { [ scan $how {%s %s} \
                              offset length ] < 2} \
            {
                # format error .. ignore it.
                #puts "format error for output; ignoring"
                return
            }
            #puts "OUTPUT: ## $offset $length"
            handle_output_display $offset $length
        }
    }
}

proc handle_resize { size } \
{
    global exnode
    global config

# #puts "entering new_exnode $size"

    set exnode("cols") 0
    set exnode("size") $size
}

proc init_exnode { } \
{
    global exnode
    global config

    set exnode("arrows") 0
    set exnode("animdelay") 300
    set exnode("cols") 0
    set exnode("size") 0

    set extray $config("extray")
    set width  $config("width")
    set height $config("height")

    # Text beginning (upper left)
    set exnode("xtbegin") 5          
    set exnode("ytbegin") [ expr $height + 5 ]

                                   # Exnode display stuff
    set exnode("xincr") [ expr $width / 14 ]
    set exnode("yincr") [ expr $extray / 12 ]
    set exnode("ytop") [ expr $height + $exnode("yincr") * 0.5 ]
    set exnode("ybot") [ expr $height + $exnode("yincr") * 11.5 ]
    set exnode("yheight") [ expr $exnode("ybot") - $exnode("ytop") ]
    set exnode("xleft") [ expr $exnode("xincr") * 3]
    set exnode("xright") [ expr $exnode("xincr") * 11]
    set exnode("xrightoutput") [ expr $exnode("xincr") * 12]
}

proc handle_output_display { offset length } \
{
  global exnode
  global color
  global indices 
  global xc
  global yc

  set xleft $exnode("xleft")
  set xrightoutput $exnode("xrightoutput")
  set xwidth $exnode("xincr")
  set ytop $exnode("ytop")
  set ybot $exnode("ybot")
  set yheight [ expr $ybot - $ytop ]

  set xl $xrightoutput
  set cdepot $indices(unknown:1)

  set ylo [ expr $ytop + $yheight * $offset / $exnode("size") ]
  set yhi [ expr $ytop + $yheight * ( $offset + $length ) / $exnode("size") ]

  #puts "MOOO"
  .mv.c create rectangle $xl $ylo [ expr $xl + $xwidth -3 ] $yhi \
              -outline white -fill $color($cdepot) -tag jkl
  .mv.c lower jkl b

}
proc handle_dlslice_display { key offset length } \
{
    global exnode
    global color
    global indices 
    global xc
    global yc
    global arrow_width
    global arrow_shape_l

    set xleft $exnode("xleft")
    set xright $exnode("xright")
    set xwidth $exnode("xincr")
    set ytop $exnode("ytop")
    set ybot $exnode("ybot")
    set yheight [ expr $ybot - $ytop ]

    set xl $xright

    if { [ info exists indices($key) ] } \
    {
        set cdepot $indices($key)
    } else {
        set cdepot $indices(unknown:1)
    }
    set ylo [ expr $ytop + $yheight * $offset / $exnode("size") ]
    set yhi [ expr $ytop + $yheight * ( $offset + $length ) / $exnode("size") ]

    .mv.c create rectangle $xl $ylo [ expr $xl + $xwidth - 3] $yhi \
              -outline $color($cdepot) -fill $color($cdepot) -tag dlslice_1
    .mv.c lower dlslice_1 b

}
proc handle_dlbuffer_display { key offset length } \
{
    global exnode
    global color
    global indices 
    global xc
    global yc
    global arrow_width
    global arrow_shape_l

    set xleft $exnode("xleft")
    set xright $exnode("xright")
    set xwidth $exnode("xincr")
    set ytop $exnode("ytop")
    set ybot $exnode("ybot")
    set yheight [ expr $ybot - $ytop ]

    set xl $xright

    if { [ info exists indices($key) ] } \
    {
        set cdepot $indices($key)
    } else {
        set cdepot $indices(unknown:1)
    }
    set ylo [ expr $ytop + $yheight * $offset / $exnode("size") ]
    set yhi [ expr $ytop + $yheight * ( $offset + $length ) / $exnode("size") ]

    .mv.c create rectangle $xl $ylo [ expr $xl + $xwidth - 3] $yhi \
              -outline $color($cdepot) -fill black -width 2 -tag dlbuffer_1
    .mv.c lower dlbuffer_1 c

}
proc handle_nwsScale_display { min max index span color } \
{
    global exnode
    global config
    global indices

    set xleft  $exnode("xleft")
    set xwidth $exnode("xincr")
    set ytop   $exnode("ytop")
    set ybot   $exnode("ybot")
    set range  [ expr $max - $min ]
    set yheight [ expr $ybot - $ytop ]

    set chigh   [ expr $index + $span ]
##puts "top: $ytop bot: $ybot range: $range index: $index"
    set ylo     [ expr $ybot - ($yheight * (($index - $min)/($max-$min))) ]
    set yhi     [ expr $ybot - ($yheight * (($chigh - $min)/($max-$min))) ]
##puts "ylo: $ylo yhi: $yhi"
#    set ylo     [ expr $yheight - ($ytop + ($yheight) * $index / $range) ]
#    set yhi     [ expr $yheight - ($ytop + ($yheight) * $chigh / $range) ]
    set yw      [ expr $yhi - $ylo ]

    .mv.c create rectangle $xleft $ylo \
                      [ expr $xleft + $xwidth ] $yhi \
              -outline white -fill $color -tag nwsScale_a
    .mv.c lower nwsScale_a b
    set disp_text [ format "%.1f - %.1f" $chigh $index ]
    .mv.c create text [expr $xleft + $xwidth + $xwidth/2.0 ] [ expr $ylo + $yw/2.0 ]  \
                -font {Helvetica 10} -text $disp_text -fill white -justify center
}

proc handle_mapping2_display { col chunkid offset length disp_text } \
{
    global exnode
    global config
    global color
    global indices

    set xleft  $exnode("xleft")
    set xwidth $exnode("xincr")
    set ytop   $exnode("ytop")
    set ybot   $exnode("ybot")
    set yheight [ expr $ybot - $ytop ]


    set key    "$col $chunkid data"
    set l       $exnode($key)
    set csz     [ lindex $l 0 ]
    set coff    [ lindex $l 1 ]
    set cdepot  [ lindex $l 2 ]
    set alive   [ lindex $l 3 ]
    set chigh   [ expr $offset + $length ]
    set ylo     [ expr $ytop + ($yheight) * $offset / $exnode("size") ]
    set yhi     [ expr $ytop + ($yheight) * $chigh / $exnode("size") ]
    set yw      [ expr $yhi - $ylo ]
    if { $cdepot >= 0 } {
        .mv.c create polygon [ expr $xleft + $col*$xwidth ] $ylo \
                      [ expr $xleft + ($col+1.0)*$xwidth -3 ] $ylo \
                      [ expr $xleft + ($col+1.0)*$xwidth -3 ] $yhi \
                      [ expr $xleft + $col*$xwidth ] $yhi \
                      [ expr $xleft + $col*$xwidth + ($xwidth/4.0) ] [ expr ($yhi+$ylo)/2.0 ] \
              -outline $color($cdepot) -fill $color($cdepot) -tag mapping2_a
        .mv.c lower mapping2_a b
    } else {
        .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth -3 ] $yhi \
              -outline black -fill black
    }
    if { $disp_text == "DEAD"  } \
    {
        set xl [ expr $xleft + $col * $xwidth + $xwidth * .2 ]
        set xr [ expr $xleft + $col * $xwidth + $xwidth * .8 ]
        set yl [ expr $ylo + $yw * .2 ]
        set yh [ expr $ylo + $yw * .8 ]
        .mv.c create line $xl $yl $xr $yh -width 2
        .mv.c create line $xl $yh $xr $yl -width 2
    } else {
# puts "yw: $yw"
        if { $disp_text != ""  && $yw > 10 } {
            set xl [ expr $xleft + $col * $xwidth + $xwidth * .5 ]
            set yh [ expr $ylo + $yw * .5 ]
            .mv.c create text $xl $yh -font {Helvetica 8} -text "$disp_text"
        }
    }
}

proc handle_allocation_display { col chunkid }  \
{
    global exnode
    global config
    global color
    global indices

    set expire "abc"
    set xleft  $exnode("xleft")
    set xwidth $exnode("xincr")
    set ytop   $exnode("ytop")
    set ybot   $exnode("ybot")
    set yheight [ expr $ybot - $ytop ]

    set key    "$col $chunkid data"
    set l       $exnode($key)
    set csz     [ lindex $l 0 ]
    set coff    [ lindex $l 1 ]
    set cdepot  [ lindex $l 2 ]
    set alive   [ lindex $l 3 ]
    set chigh   [ expr $coff + $csz ]
#    set ylo     [ expr $ytop + $yheight * $coff / $exnode("size") + 3]
#    set yhi     [ expr $ytop + $yheight * $chigh / $exnode("size") - 3]
    set ylo     [ expr $ytop + $yheight * $coff / $exnode("size") ]
    set yhi     [ expr $ytop + $yheight * $chigh / $exnode("size") ]
    set yw      [ expr $yhi - $ylo ]
    if { $cdepot >= 0 } {
#.mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
#                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
#              -outline $color($cdepot) -fill $color($cdepot)
    .mv.c create rectangle [ expr $xleft +($col*$xwidth) ] $ylo \
                           [ expr $xleft + (($col+1)* $xwidth) - 4 ] $yhi \
                  -outline white -fill black -width 2 -tag allocation_1
    .mv.c lower allocation_1 d
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth -3 ] $yhi \
              -outline $color($cdepot) -fill black -tag allocation_2
    .mv.c lower allocation_2 d
  } else {
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
              -outline white -fill black
  }
}

proc handle_from_display { col chunkid keySrc offset length }  \
{
    global exnode
    global config
    global color
    global indices

    set expire "abc"
    set xleft  $exnode("xleft")
    set xwidth $exnode("xincr")
    set ytop   $exnode("ytop")
    set ybot   $exnode("ybot")
    set yheight [ expr $ybot - $ytop ]

    set key    "$col $chunkid data"
    set l       $exnode($key)
    set csz     [ lindex $l 0 ]
    set coff    [ lindex $l 1 ]
    set cdepot  [ lindex $l 2 ]
    set alive   [ lindex $l 3 ]
    set chigh   [ expr $offset + $length ]
    set ylo     [ expr $ytop + $yheight * $offset / $exnode("size") ]
    set yhi     [ expr $ytop + $yheight * $chigh / $exnode("size") ]
    set yw      [ expr $yhi - $ylo ]
    if { $cdepot >= 0 } {
    if { [ info exists indices($keySrc)] } \
    {
        set c $indices($keySrc)
    } else {
        if { $keySrc == "" } {
            set c $cdepot
        } else {
            set c $indices(unknown:1)
        }
    }
    .mv.c create polygon [ expr $xleft + $col * $xwidth ] $ylo \
                      [ expr $xleft + $col*$xwidth ] $ylo \
                      [ expr $xleft + $col*$xwidth + $xwidth/4.0 ] [expr ($ylo + $yhi)/2 ] \
                      [ expr $xleft + $col*$xwidth ] $yhi \
                      [ expr $xleft + $col * $xwidth ] $yhi \
              -outline $color($c) -fill $color($c) -tag allocation_3
    .mv.c lower allocation_3 c
  } else {
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
              -outline white -fill black
  }
}

proc handle_begin_display { col chunkid keySrc }  \
{
    global exnode
    global config
    global color
    global indices

    set expire "abc"
    set xleft  $exnode("xleft")
    set xwidth $exnode("xincr")
    set ytop   $exnode("ytop")
    set ybot   $exnode("ybot")
    set yheight [ expr $ybot - $ytop ]

    set key    "$col $chunkid data"
    set l       $exnode($key)
    set csz     [ lindex $l 0 ]
    set coff    [ lindex $l 1 ]
    set cdepot  [ lindex $l 2 ]
    set alive   [ lindex $l 3 ]
    set chigh   [ expr $coff + $csz ]
#    set ylo     [ expr $ytop + $yheight * $coff / $exnode("size") + 3]
#    set yhi     [ expr $ytop + $yheight * $chigh / $exnode("size") - 3]
    set ylo     [ expr $ytop + $yheight * $coff / $exnode("size") ]
    set yhi     [ expr $ytop + $yheight * $chigh / $exnode("size") ]
    set yw      [ expr $yhi - $ylo ]
    if { $cdepot >= 0 } {
#.mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
#                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
#              -outline $color($cdepot) -fill $color($cdepot)
    if { [ info exists indices($keySrc)] } \
    {
        set c $indices($keySrc)
    } else {
        if { $keySrc == "" } {
            set c $cdepot
        } else {
            set c $indices(unknown:1)
        }
    }
    .mv.c create rectangle [ expr $xleft +($col*$xwidth) ] $ylo \
                           [ expr $xleft + (($col+1)* $xwidth) - 4 ] $yhi \
                  -outline white -fill black -width 2 -tag allocation_1
    .mv.c lower allocation_1 c
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth -3 ] $yhi \
              -outline $color($cdepot) -fill black -tag allocation_2
    .mv.c lower allocation_2 c
    .mv.c create polygon [ expr $xleft + $col * $xwidth ] $ylo \
                      [ expr $xleft + $col*$xwidth ] $ylo \
                      [ expr $xleft + $col*$xwidth + $xwidth/4.0 ] [expr ($ylo + $yhi)/2 ] \
                      [ expr $xleft + $col*$xwidth ] $yhi \
                      [ expr $xleft + $col * $xwidth ] $yhi \
              -outline $color($c) -fill $color($c) -tag allocation_3
    .mv.c lower allocation_3 c
  } else {
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
              -outline white -fill black
  }
}

proc locate_colum_id { id offset length key } {
  global exnode
  global indices
#xx offset size depot 

  if { [info exists indices($key)] } \
  {
      set depot $indices($key)
  } else  {
      set depot $indices(unknown:1)
  }
  for {set i 0} {$i < $exnode("cols")} {incr i} {
    set nch $exnode($i)
    for {set j 0} {$j < $nch} {incr j} {
      set key "$i $j data"
      set l $exnode($key)
      set csz    [ lindex $l 0 ]
      set coff   [ lindex $l 1 ]
      set cdepot [ lindex $l 2 ]
      set cid    [ lindex $l 4 ]
      if { $cid == $id &&  $offset == $coff && $csz == $length && $cdepot == $depot } \
      {
          return [ list $i $j ]
      }
    }
  }
  return [ list -1 -1 ]
}

proc handle_arrow2_delete { key offset length } \
{
  global exnode

  set arrow_desc "arrow2_${offset}_${length}"
  after 500 [ list .mv.c delete $arrow_desc ]
}

proc handle_arrow3_delete { keySrc keyDst id } \
{
    global exnode
    set a_tag "arrow3_${keySrc}_${keyDst}_${id}"
    set a_tag_1 "arrow3_${keySrc}_${keyDst}_${id}_1"
    set a_tag_2 "arrow3_${keySrc}_${keyDst}_${id}_2"
    set m_tag "m_${a_tag}"
    .mv.c delete $a_tag
    .mv.c delete $a_tag_1
    .mv.c delete $a_tag_2
    .mv.c delete $m_tag
}
proc sphere_distance { lat1 lon1 lat2 lon2 } \
{
    set lat1 [ expr { $lat1 * 0.017453293 }
    set lon1 [ expr { $lon1 * 0.017453293 }
    set lat2 [ expr { $lat2 * 0.017453293 }
    set lon2 [ expr { $lon2 * 0.017453293 }

    set dlat [ expr { $lat2 - $lat1 } ]
    set dlon [ expr { $lon2 - $lon1 } ]

    set a [ expr { pow(sin($dlat/2),2) + cos($lat1) * cos($lat2) *pow(sin($dlon/2),2) } ] 
    if { 1 <= [ expr sqrt ($a) ] } {
        set c 1
    } else {
        set c [ expr { sqrt($a) } ]
    }
    return [expr {3956*$c} ]
}

proc handle_arrow3_display { keySrc keyDst id level msg } \
{
    global exnode
    global indices
    global xc
    global yc
    global glat
    global glon
    global arrow_width
    global arrow_shape_l
    global color_scale
    global config

    if { [info exists indices($keySrc)] } \
    {
        set ind1 $indices($keySrc)
    } else {
        #puts "UNKNOWN SOURCE: $keySrc"
        set ind1 $indices(unknown:1)
    }
    if { [info exists indices($keyDst)] } \
    {
      set ind2 $indices($keyDst)
    } else {
      #puts "UNKNOWN DEST: $keyDst"
      set ind2 $indices(unknown:1)
    }

# These numbers are the relative position on the display, not literal.  This
# way it should make sense for any map.
    #puts "ind1: $ind1 "
    #puts "ind2: $ind2 "
    #puts "glon1: $glon($ind1)"
    #puts "glon2: $glon($ind2)"

    set wrap_point_y [ expr { $config("height") / 2 } ]

    if { $glon($ind1) > $glon($ind2) } {
        set lon2 $glon($ind1)
        set lon1 $glon($ind2)
    } else {
        set lon1 $glon($ind1)
        set lon2 $glon($ind2)
    }

    set b [ expr { $lon1 - $lon2 + 360 } ] 
    set a [ expr { $lon2 - $lon1 } ]

    if { $b < $a } \
    {
        # wrap 
        set a_tag_1 "arrow3_${keySrc}_${keyDst}_${id}_1"
        set a_tag_2 "arrow3_${keySrc}_${keyDst}_${id}_2"
        #puts "WRAPPING !!!! ____!!!!____!!!__"
        if { $glon($ind1) > $glon($ind2) }\
        {
            .mv.c create line $xc($ind1) $yc($ind1) \
                          $config("width") $wrap_point_y \
                          -fill $color_scale($level) -width $arrow_width -tag $a_tag_1  \
                          -arrow last -arrowshape $arrow_shape_l
            .mv.c create line 0 $wrap_point_y \
                          $xc($ind2) $yc($ind2) \
                          -fill $color_scale($level) -width $arrow_width -tag $a_tag_2  \
                          -arrow last -arrowshape $arrow_shape_l
        } else {
            .mv.c create line $xc($ind1) $yc($ind1) \
                          0 $wrap_point_y \
                          -fill $color_scale($level) -width $arrow_width -tag $a_tag_1  \
                          -arrow last -arrowshape $arrow_shape_l
            .mv.c create line $config("width") $wrap_point_y \
                          $xc($ind2) $yc($ind2) \
                          -fill $color_scale($level) -width $arrow_width -tag $a_tag_2  \
                          -arrow last -arrowshape $arrow_shape_l
        }
        .mv.c lower $a_tag_1 d
        .mv.c lower $a_tag_2 d
    } else { 
        # draw across map.
        set a_tag "arrow3_${keySrc}_${keyDst}_${id}"
        .mv.c create line $xc($ind1) $yc($ind1) \
                          $xc($ind2) $yc($ind2) \
                          -fill $color_scale($level) -width $arrow_width -tag $a_tag  \
                          -arrow last -arrowshape $arrow_shape_l
        .mv.c lower $a_tag d
        set m_tag "m_${a_tag}"
        .mv.c create text [ expr ($xc($ind1) + $xc($ind2))/2.0 ] \
                      [ expr (($yc($ind1) + $yc($ind2))/2.0) - 10 ] \
                      -anchor s -text $msg -justify center \
                      -fill white -font {Helvetica 12 bold}  -tag $m_tag
        .mv.c lower $m_tag c
    }

}

proc handle_arrow2_display { key offset length } \
{
  global exnode
  global color
  global indices 
  global xc
  global yc
  global arrow_width
  global arrow_shape_l

  set xleft $exnode("xleft")
  set xwidth $exnode("xincr")
  set xright $exnode("xright")
  set ytop $exnode("ytop")
  set ybot $exnode("ybot")
  set yheight [ expr $ybot - $ytop ]

  set xl $xright
#[ expr $xleft + ( $exnode("cols") + 1 ) * $xwidth ]

  if { [ info exists indices($key) ] } \
  {
    set cdepot $indices($key)
  } else {
    set cdepot $indices(unknown:1)
  }
  set ylo [ expr $ytop + $yheight * $offset / $exnode("size") ]
  set yhi [ expr $ytop + $yheight * ( $offset + $length ) / $exnode("size") ]

  set arrow_desc "arrow2_${offset}_${length}"
  #puts "display_rtdownload $arrow_desc"

#.mv.c create rectangle $xl $ylo [ expr $xl + $xwidth ] $yhi \
#              -outline white -fill $color($cdepot)
  .mv.c create line $xc($cdepot) $yc($cdepot) \
                    [ expr $xl + $xwidth / 2 ] \
                    [ expr ( $ylo + $yhi ) / 2 ] \
                    -fill blue -arrow last \
                    -width $arrow_width -tag $arrow_desc \
                    -arrowshape $arrow_shape_l
  .mv.c lower $arrow_desc a
}

proc handle_arrow1_display { col chunkid depotname } {
  global exnode
  global xc
  global yc
  global arrow_width
  global arrow_shape_l

  set xleft $exnode("xleft")
  set xwidth $exnode("xincr")
  set ytop $exnode("ytop")
  set ybot $exnode("ybot")
  set yheight [ expr $ybot - $ytop ]

  set key "$col $chunkid data"
  set l $exnode($key)
  set csz [ lindex $l 0 ]
  set coff [ lindex $l 1 ]
  set cdepot [ lindex $l 2 ]
  set chigh [ expr $coff + $csz ]
  set ylo [ expr $ytop + $yheight * $coff / $exnode("size") ]
  set yhi [ expr $ytop + $yheight * $chigh / $exnode("size") ]
  if { $cdepot >= 0 } {
         #puts "\tTAG: arrow_${csz}_${coff}_${depotname}"
        set arrow_tag "arrow_${csz}_${coff}_${depotname}"
        .mv.c create line [ expr $xleft + $col * $xwidth + $xwidth / 2 ] \
                          [ expr ( $ylo + $yhi ) / 2 ] \
                          $xc($cdepot) $yc($cdepot) -fill blue -arrow last \
                          -width $arrow_width -tag $arrow_tag \
                          -arrowshape $arrow_shape_l
        .mv.c lower $arrow_tag a
  }
}
proc handle_arrow1_delete { id offset length key } \
{
  global exnode
  #puts "\tUnTAG: arrow_${length}_${offset}_${key}"
  .mv.c delete "arrow_${length}_${offset}_${key}"
}

proc handle_mapping_delete { col chunkid } \
{
    global exnode
    global indices

    set key "$col $chunkid data"
    set l $exnode($key)
    set csz [ lindex $l 0 ]
    set coff [ lindex $l 1 ]
    set cdepot [ lindex $l 2 ]
    set exnode($key) [ list $csz $coff -1 -1 -1 ]

    handle_mapping2_display $col $chunkid $coff $csz ""
    return 
}


# chunk data is       size offset depot-id alive
# depot is -1 if there is no depot for the chunk

# exnode(col id data) -> contains the chunk data for column col, id id
# note, chunks can be unsorted.

proc exnode_new_column {} {
  global exnode

  set newcol $exnode("cols")
  set exnode("cols") [ expr $newcol + 1 ]
  set exnode($newcol) 1
  set a [ list a b c ]
  set key "$newcol 0 data"
  set exnode($key) [ list $exnode("size") 0 -1 -1 -1 ]
}

proc print_exnode {} {
  global exnode

  for {set i 0} {$i < $exnode("cols")} {incr i} {
    set nch $exnode($i)
    #puts "Column $i -- $nch chunks"
    for {set j 0} {$j < $nch} {incr j} {
      set key "$i $j data"
      #puts $exnode($key)
    }
  }
}


proc display_exnode_chunk { col chunkid seg expire} {
  global exnode
  global color

  set xleft $exnode("xleft")
  set xwidth $exnode("xincr")
  set ytop $exnode("ytop")
  set ybot $exnode("ybot")
  set yheight [ expr $ybot - $ytop ]

  set key "$col $chunkid data"
  set l $exnode($key)
  set csz [ lindex $l 0 ]
  set coff [ lindex $l 1 ]
  set cdepot [ lindex $l 2 ]
  set alive [ lindex $l 3 ]
  set chigh [ expr $coff + $csz ]
  set ylo [ expr $ytop + $yheight * $coff / $exnode("size") ]
  set yhi [ expr $ytop + $yheight * $chigh / $exnode("size") ]
  set yw [ expr $yhi - $ylo ]
  if { $cdepot >= 0 } {
#.mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
#                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
#              -outline $color($cdepot) -fill $color($cdepot)
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
              -outline $color($cdepot) -fill black -width 3
  } else {
    .mv.c create rectangle [ expr $xleft + $col * $xwidth ] $ylo \
                           [ expr $xleft + ($col+1) * $xwidth ] $yhi \
              -outline white -fill black
  }
  if { $alive == 0 } {
    set xl [ expr $xleft + $col * $xwidth + $xwidth * .2 ]
    set xr [ expr $xleft + $col * $xwidth + $xwidth * .8 ]
    set yl [ expr $ylo + $yw * .2 ]
    set yh [ expr $ylo + $yw * .8 ]
    .mv.c create line $xl $yl $xr $yh -width 2
    .mv.c create line $xl $yh $xr $yl -width 2
  } else {
    if { $seg != -1 } {
        set xl [ expr $xleft + $col * $xwidth + $xwidth * .5 ]
        set yh [ expr $ylo + $yw * .5 ]
        .mv.c create text $xl $yh -font {Helvetica 8} -text "($seg) $expire"
    }
  }
}

proc display_exnode_arrow { col chunkid } {
  global exnode
  global xc
  global yc
  global arrow_width
  global arrow_shape_l

  set xleft $exnode("xleft")
  set xwidth $exnode("xincr")
  set ytop $exnode("ytop")
  set ybot $exnode("ybot")
  set yheight [ expr $ybot - $ytop ]

  set key "$col $chunkid data"
  set l $exnode($key)
  set csz [ lindex $l 0 ]
  set coff [ lindex $l 1 ]
  set cdepot [ lindex $l 2 ]
  set chigh [ expr $coff + $csz ]
  set ylo [ expr $ytop + $yheight * $coff / $exnode("size") ]
  set yhi [ expr $ytop + $yheight * $chigh / $exnode("size") ]
  if { $cdepot >= 0 } {
        .mv.c create line [ expr $xleft + $col * $xwidth + $xwidth / 2 ] \
                          [ expr ( $ylo + $yhi ) / 2 ] \
                          $xc($cdepot) $yc($cdepot) -fill blue -arrow last \
                          -width $arrow_width -tag lastarrow -tag arrows \
                      -arrowshape $arrow_shape_l
  }
}

proc fast_refresh {} {
   clear
   draw_depots
   display_exnode_fast
}

proc display_exnode_fast {} {
  global exnode

  set width  [ image width us ]
  set height [ image height us ]
  set height [ expr $height ]

  set xbegin 5
  set ybegin [ expr $height + 5 ]

  if { $exnode("size") < 0 } { 
    set disptext ""
  } else {
    set disptext "$exnode("fname")\n$exnode("orig")\n$exnode("size") bytes"  
  }
  
  .mv.c create text $xbegin $ybegin -anchor nw \
          -text $disptext \
          -justify left \
          -fill white -font {Helvetica 16 bold }

  for {set i 0} {$i < $exnode("cols")} {incr i} {
    set nch $exnode($i)
    for {set j 0} {$j < $nch} {incr j} {
      handle_allocation_display $i $j 
      handle_mapping2_display $i $j ""
    }
  }
  if { $exnode("arrows") == 1} {
    draw_arrows
  } else {
    delete_arrows
  }
}

proc display_exnode {} {
  global exnode

  set width [ image width us ]
  set height [ image height us ]
  set height [ expr $height ]

  set xbegin 5
  set ybegin [ expr $height + 5 ]

  
  if { $exnode("size") < 0 } { 
    set disptext ""
  } else {
    set disptext "$exnode("fname")\n$exnode("orig")\n$exnode("size") bytes"  
  }
  
  .mv.c create text $xbegin $ybegin -anchor nw \
          -text $disptext \
          -justify left \
          -fill white -font {Helvetica 16 bold }

  set exnode("xdanim") [ list ]
  set exnode("xdindex") 0
  for {set i 0} {$i < $exnode("cols")} {incr i} {
    set nch $exnode($i)
    for {set j 0} {$j < $nch} {incr j} {
      lappend exnode("xdanim") $i $j
    }
  }

  display_exnode_animate 
}

proc display_exnode_animate { } {
  global exnode

  .mv.c delete arrows

  if { $exnode("xdindex") < [ llength $exnode("xdanim") ] } {
    set i [ lindex $exnode("xdanim") $exnode("xdindex") ]
    set exnode("xdindex") [ expr $exnode("xdindex") + 1 ]
    set j [ lindex $exnode("xdanim") $exnode("xdindex") ]
    set exnode("xdindex") [ expr $exnode("xdindex") + 1 ]
    display_exnode_chunk $i $j  -1 0
    display_exnode_arrow $i $j 
    after $exnode("animdelay") display_exnode_animate 
  } else {
    if { $exnode("arrows") == 1} {
      draw_arrows
    } else {
      delete_arrows
    }
  }
}

proc delete_arrows { } {
  global exnode

  .mv.c delete arrows
  set exnode("arrows") 0
  .mv.buttons.draw_arrows configure -text "Draw Arrows" -command draw_arrows
}

proc nullproc { } {
}

proc draw_arrows { } {
  global exnode

  for {set i 0} {$i < $exnode("cols")} {incr i} {
    set nch $exnode($i)
    for {set j 0} {$j < $nch} {incr j} {
      display_exnode_arrow $i $j 
    }
  }
  set exnode("arrows") 1
  .mv.buttons.draw_arrows configure -text "Delete Arrows" -command delete_arrows
  print_exnode
}

proc add_exnode_chunk { depotid size offset alive id } {
  global exnode

  set high [ expr $size + $offset ]
  for {set i 0} {$i < $exnode("cols")} {incr i} \
  {
    set nch $exnode($i)
    for {set j 0} {$j < $nch} {incr j} \
    {
      set key "$i $j data"
      set l $exnode($key)
      set csz [ lindex $l 0 ]
      set coff [ lindex $l 1 ]
      set cdepot [ lindex $l 2 ]
      set chigh [ expr $coff + $csz ]
      if { $cdepot < 0 && $coff <= $offset && $chigh >= $high } \
      {
        return [ exnode_insert $depotid $size $offset $alive $i $j $id ]
      }
    }
  }
  exnode_new_column
  return [ exnode_insert $depotid $size $offset $alive $i 0 $id ]
}

proc trim_chunk { offset size depot } {
  global exnode
  global indices

  if { [info exists indices($depot)] } \
  {
      set depot $indices($depot)
  } else  {
      set depot $indices(unknown:1)
  }
  for {set i 0} {$i < $exnode("cols")} {incr i} {
    set nch $exnode($i)
    for {set j 0} {$j < $nch} {incr j} {
      set key "$i $j data"
      set l $exnode($key)
      set csz [ lindex $l 0 ]
      set coff [ lindex $l 1 ]
      set cdepot [ lindex $l 2 ]
      if { $offset == $coff && $csz == $size && $cdepot == $depot } {
        set exnode($key) [ list $size $offset -1 -1 -1 ]
        display_exnode_chunk $i $j -1 0
        return 
      }
    }
  }
}

proc exnode_insert { depotid size offset alive col cnum id } {
  global exnode
  global xc
  global yc
  global yb

  set key "$col $cnum data"
  set l $exnode($key)
  set csz [ lindex $l 0 ]
  set coff [ lindex $l 1 ]
  set cdepot [ lindex $l 2 ]
  set chigh [ expr $coff + $csz ]
  if { $coff < $offset } {
    set newoff $coff
    set newsize [ expr $offset - $coff ]
    set key2 "$col $exnode($col) data"
    incr exnode($col)
    set exnode($key2) [ list $newsize $newoff -1 -1 $id ]
    set coff $offset
    set csz [ expr $csz - $newsize ]
  } 
  if { $csz > $size } {
    set newoff [ expr $coff + $size ]
    set newsize [ expr $csz - $size ]
    set key2 "$col $exnode($col) data"
    incr exnode($col)
    set exnode($key2) [ list $newsize $newoff -1 -1 $id ]
    set csz $size
  }
  set exnode($key) [ list $size $offset $depotid $alive $id ]      
  return [ list $col $cnum ]
}

proc close_sock { sock } {
  global exnode
  global config

  set f $exnode("filename")
  incr config(connections) -1

#if { $f == "SOCKET" } {
    close $sock
    set exnode("filename") "NULL"
    .mv.buttons.status configure -text "$config(connections) Active Connection(s)"
    return
#  }
}

proc close_socket {} {
  global exnode

  set f $exnode("filename")
  set gf $exnode("filedesc") 

  if { $f == "SOCKET" } {
    close $gf
    set exnode("filename") "NULL"
    .mv.c delete "awaitConnect"
    .mv.c create text 10 [ expr $config("height") - 10 ] -anchor w \
          -text "Awaiting Connection.." \
          -justify left -tag "awaitConnect" \
          -fill white -font {Helvetica 16 bold }
    return
  }
}

proc read_display_config { file } {
    global env
    global depot_group_list
    global config
    global color_scale

    set config("depotsize") 22
    set scalecnt 0
    if { [ catch { set gf [ open $file r ] } ] } \
    {
        #puts "Could not open DISPLAY CONFIG FILE '$file'!"
    } else {
        set x 1
        while { $x != -1 } \
        {
            set x [gets $gf line]
            if { $x == -1 } {
                break
            }
            set line [string trim $line]

            set l [ split $line {} ]
            set t [lindex $l 0 ]
            if { $t == "#" } {
                # #puts "skipping $line"
                continue;
            } 
            set l [ split $line ]
            set cmd [lindex $l 0] 
            switch $cmd \
            {
                GRID
                {
                   set config("rows") [lindex $l 1]
                   set config("cols") [lindex $l 2]
                }
                IMAGE
                {
                   set config("picturefile") [ join [ lrange $l 1 end ] ]
                }
                PORT
                {
                   set config("port") [lindex $l 1]
                }
                DEPOTSIZE 
                {
                    set config("depotsize") [lindex $l 1]
                }
                KEYPOINT1
                {
                    set config("lat1") [lindex $l 1]
                    set config("lon1") [lindex $l 2]

                    set config("lat1") [ expr $config("lat1") * 1.0 ]
                    set config("lon1") [ expr $config("lon1") * 1.0 ]
                }
                KEYPOINT2
                {
                    set config("lat2") [lindex $l 1]
                    set config("lon2") [lindex $l 2]

                    set config("lat2") [ expr $config("lat2") * 1.0 ]
                    set config("lon2") [ expr $config("lon2") * 1.0 ]
                }
                NAMES
                {
                    set config("shownames") [lindex $l 1]
                }
                ARROWWIDTH
                {
                    set config("arrowwidth") [lindex $l 1]
                }
                FONTCOLOR
                {
                   set config("fontcolor") [lindex $l 1]
                }
                SCALE
                {
                    set i [lindex $l 1]
                    set color [lindex $l 2]
                    set color_scale($i) "#$color"
                    incr scalecnt
                }
                GROUP
                {
                    set lat1 [lindex $l 1]
                    set lon1 [lindex $l 2]
                    set posX [lindex $l 3]
                    set posY [lindex $l 4]
                    set groupname [ join [lrange $l 5 end]]
                    set key "$groupname:$lat1:$lon1:$posX:$posY"
                    set depot_group_list($key) ""
                }
                DEPOT
                {
                    set depot_info [lrange $l 1 end]
                    # #puts "depot_info == $depot_info"
                    lappend depot_group_list($key) $depot_info
                }
                ENDGROUP
                {
                   # is this necessary?
                }
            }
        }
    }

    set config("scalecnt") $scalecnt

#foreach key [ array names depot_group_list] {
#        #puts "key: $key"
#        #puts "$depot_group_list($key)"
#        foreach l $depot_group_list($key) {
#             set length [llength $l]
#             #puts "    length : $length"
#             #puts "\t$l"
#             set x [lindex $l 2]
#             #puts $x
#        }
#    }

}






proc bad_file { s } {
    global exnode

    set f $exnode("filename")
    set gf $exnode("filedesc") 

    if {$f != "SOCKET"} {
      tk_dialog .mv.error "Bad input file" \
            "Error:\nFile $f\nBad Input File\n$s" \
                    {}  0  "OK"
      close $gf
      set exnode("filename") "NULL"
      exit
      return
    } else {
       next_event skip_to_end
    }
}

proc skip_to_end { } {
  global exnode

  set f $exnode("filename")
  set gf $exnode("filedesc") 

  if {![eof $gf] && ![ catch {gets $gf line} ] } {
#  if \{ \[ gets $gf line \] >= 0 \} \{
    if { [ scan $line "%s" key ] == 1 } {
      if { $key == "END" } { 
        end_of_input 
        return
      }  else {
        next_event skip_to_end
        return
      }
    }
  }
  if { $f == "SOCKET" } {
    close_socket
  } else {
    close $gf
  }
  return
}

proc next_event { procedure } {
  global exnode

  set f $exnode("filename")
  set gf $exnode("filedesc") 

  if {$f == "SOCKET"} {
    fileevent $gf readable $procedure
  } else {
    after idle $procedure
    return
  }
}
  
proc end_of_input { } {
  global exnode

  set f $exnode("filename")
  set gf $exnode("filedesc") 

  if {$f == "SOCKET"} {
    fileevent $gf readable dispatch
  } else {
    set exnode("filename") "NULL"
    close $gf
    if { $exnode("savefile") == "SOCKET" } {
      set exnode("filename") $exnode("savefile")
      set exnode("filedesc") $exnode("savedesc")
      set exnode("savefile") "NULL"
    }
  }
}

proc garbage_collect {} \
{
  set l [ .mv.c find all ]
  set len [ llength $l ]
  for {set i 0} {$i < $len} {incr i} \
  {
      set tag [ lindex $l $i ]
##puts "$i -- $tag"
      .mv.c delete $tag
  }
}
  
proc main {} \
{
  global usmap 
  global cols
  global rows
  global extray
  global argc
  global argv
  global fontcolor
  global arrow_width
  global arrow_shape_l
  global config
  global env

  . config -bg black 
  frame .mv -background black -borderwidth 0
  wm title . "LoRS View -- Visualization of Logistical Runtime System Tools"
  pack .mv -fill both -expand yes
#-ill x

#set picturefile "map.gif"
#  set fontcolor "white"
  set cfp "$env(HOME)/.xndcommand"
  set configfile "$cfp/newusa.cfg"
  set draw_grid 0
  set config(hideoff) 0

  for {set i 0} {$i < $argc} {incr i} \
  {
    set arg1 [ lindex $argv $i ]
    puts "$arg1 "
    puts [lindex $argv [expr $i + 1] ]
    if { $arg1 == "-picture" } { 
       set picturefile [ lindex $argv [expr $i + 1 ] ]
    } 
    if { $arg1 == "-fontcolor" } {
       set fontcolor [ lindex $argv [expr $i + 1 ] ]
    }
    if { $arg1 == "-config" } {
       set configfile [ lindex $argv [expr $i + 1 ] ]
    }
    if { $arg1 == "-grid" } {
        set draw_grid 1
    }
    if { $arg1 == "-hideoff" } {
        set config(hideoff) 1
    } 
  }
  read_display_config $configfile
  set config("block") 0
  for {set i 0} {$i < $argc} {incr i} \
  {
    set arg1 [ lindex $argv $i ]
    if { $arg1 == "-port" } {
        set config("port") [ lindex $argv [expr $i+1] ]
    }
    if { $arg1 == "-block" } {
        set config("block") 1
    }
  }
  set fontcolor  $config("fontcolor")
  set picturefile $config("picturefile")
  set config(connections) 0
#
# DEPOT SIZE
#
  set rows $config("rows")
  set cols $config("cols")
  set arrow_width $config("arrowwidth")
  set arrow_shape_l [ list 8 8 4 ]

  image create photo us -file $picturefile

  set width [ image width us ]
  set config("width") $width
  set config("height") [ image height us ]
  set height [ expr $config("height")  ]
  
  set extray 270
  set config("extray") 270

  init_exnode

  canvas .mv.c  -width $width -height [ expr $height + $extray  ] \
        -background black  -borderwidth 0 -relief solid 
  pack .mv.c -fill y -anchor e -expand yes
#-fill x

  frame .mv.buttons -background black -width $width 
#button .mv.buttons.fredraw -text "Quick Redraw" -command fast_refresh \
#    -foreground red -background black 
  button .mv.buttons.clear -text "Clear"  -command clear_exnode \
    -foreground red -background black
  button .mv.buttons.draw_names -text "Draw Names" -command draw_names \
    -foreground red -background black
  button .mv.buttons.draw_arrows -text "-"  -command nullproc \
    -foreground red -background black
  open_socket
  label  .mv.buttons.status -background black -text "0 Active Connection(s)" \
        -foreground red
  button .mv.buttons.quit -text Quit  -command exit \
    -foreground red -background black

  pack .mv.buttons.quit -side left -fill x -expand yes
  pack .mv.buttons.clear -side left -fill x -expand yes
  pack .mv.buttons.draw_arrows -side left -fill x -expand yes
  pack .mv.buttons.status -side left -fill x -expand yes
  pack .mv.buttons -side bottom -fill both -expand no
  
  read_depots "depots.txt"

  #set of [ open "out.txt" w ]
  #set exnode("log") $of
  clear_exnode
  if { $draw_grid == 1 } {
      draw_grid
  }

  set exnode("savefile") "NULL"
  set exnode("savedesc") "NULL"
  set exnode("filename") "NULL"
  set exnode("filedesc") -1

}

set script_root [pwd]
cd $script_root
main

