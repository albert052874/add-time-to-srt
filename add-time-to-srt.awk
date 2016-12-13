#!/usr/bin/awk

##########################################################
# Name : add-time-to-srt.awk
#
# Desc :
# Script to add time stamps to a subtitle file in "srt" format
#
# This script has 2 actions:
#
# 1. It inserts:
#    - in each existing subtitle
#    - the precise time of this subtitle
#    - at some place in the existing subtitle, either:
#      - above its first line
#      - or to the left of its first line
#      - or to the right of its first line
#      - or below its last line (by default)
#
# 2. It inserts:
#    - a new subtitle with the current time
#    - every 1/10 s (by default)
#    - between existing subtitles
#
# This may be useful before using the "SubFix" application.
#
# Install:
# -------
# Put "add-time-to-srt.sh" and "add-time-to-srt.awk" in the same directory
# accessible through the variable "$PATH".
#
# Usage: add-time-to-srt.sh < foo.srt > foot.srt
# -----
#
# TODO:
# ----
#
# 1. Separate 2 actions
#
# 2. Check options value
#
# ------------------------------------------------------------------------
# [jack] 161201 Version initiale: add timestamps
# ------------------------------------------------------------------------

# 10
# 00:01:37,760 --> 00:01:40,718
# Nice of you to drop by me humble abode.
#
# 11
# 00:01:41,560 --> 00:01:45,553
# My name is Bunny.
# Bugs Bunny, Esq., to be exact.

# =>

# 10
# 00:01:37,760 --> 00:01:40,718
# Nice of you to drop by me humble abode.
#
# 11
# 00:01:40,800 --> 00:01:40,900
# 00:01:40,800
#
# 12
# 00:01:40,900 --> 00:01:41,000
# 00:01:40,900
#
# 13
# 00:01:41,000 --> 00:01:41,100
# 00:01:41,000
#
# ...
#
# 17
# 00:01:41,400 --> 00:01:41,500
# 00:01:41,400
#
# 18
# 00:01:41,560 --> 00:01:45,553
# 00:01:41,560 My name is Bunny.
# Bugs Bunny, Esq., to be exact.

function string_to_time(stime) {
  split(stime, s, ",") # "O1:23:45,678" -> ["O1:23:45", "678"]
  split(s[1],  t, ":") # "O1:23:45"     -> ["O1", "23", "45"]
  return 3600*t[1] + 60*t[2] + t[3] + s[2]/1000
}

function time_to_string(time) {
    hour = int(time/3600)
    min  = int(time/60) % 60
    sec  = int(time) % 60
    ms   = 1000 * (time % 1)

    return sprintf("%02i:%02i:%02i,%03i", hour, min, sec, ms)
}

function stime_add(stime1, stime2) {
    split(stime1, s1, ",") # "O1:23:45,678" -> ["O1:23:45", "678"]
    split(s1[1],  t1, ":") # "O1:23:45"     -> ["O1", "23", "45"]
    split(stime2, s2, ",") # "O1:23:45,678" -> ["O1:23:45", "678"]
    split(s2[1],  t2, ":") # "O1:23:45"     -> ["O1", "23", "45"]
    ms = s1[2] + s2[2]
    r = 0
    if (ms >= 1000) { ms -= 1000; r = 1; }
    sec = t1[3] + t2[3] + r
    r = 0
    if (sec >= 60) { sec -= 60; r = 1; }
    min = t1[2] + t2[2] + r
    r = 0
    if (min >= 60) { min -= 60; r = 1; }
    hour = t1[1] + t2[1] + r
    # r = 0
    # if (hour >= 24) { hour -= 24; r = 1; }
    # time = 3600*hour + 60*min + sec + ms/1000
    return sprintf("%02i:%02i:%02i,%03i", hour, min, sec, ms)
}

function stime_truncate(stime) {
    split(stime, s, ",") # "O1:23:45,678" -> ["O1:23:45", "678"]
    return sprintf("%s,%03i", s[1], 0)
}

function insert_timetag(s_start_time, s_end_time) {
    print nst EOL; nst++    # The index had not yet been printed
    print s_start_time " --> " s_end_time EOL
    print s_start_time EOL  # Print the timetag alone in a line
    print EOL               # Print an empty line
}

function insert_timetags(until_time) {
    s_e_timetag = stime_add(s_b_timetag, delta)
    e_timetag  = string_to_time(s_e_timetag)
    if (e_timetag <= until_time) {
        # There is enough time to insert the first timetag subtitle
        # starting just at the end of the previous existing subtitle
        insert_timetag(previous_s_e_time, s_e_timetag)
        s_b_timetag = s_e_timetag
        s_e_timetag = stime_add(s_b_timetag, delta)
        e_timetag  = string_to_time(s_e_timetag)
    }
    while (e_timetag <= until_time) {
        # There is enough time to insert a timetag subtitle
        # starting just at the end of the previous timetag subtitle
        insert_timetag(s_b_timetag, s_e_timetag)
        s_b_timetag = s_e_timetag
        s_e_timetag = stime_add(s_b_timetag, delta)
        e_timetag  = string_to_time(s_e_timetag)
    }
}

BEGIN {
    # Default options
    default_style = "bottom"
    default_first_st_index = 1
    default_start_time_float = 0
    default_delta = "00:00:00,100"
    # Options passed as `-v` variables ("style" "delta" "end_time" "first_st_index" "start_time")
    if (style == "") {style = default_style}
    if (delta == "") {delta = default_delta}
    if (end_time != "") {end_time_float = string_to_time(end_time)}
    if (first_st_index == "") {first_st_index = default_first_st_index}
    if (start_time == "") {start_time_float = default_start_time_float}
    else {start_time_float = string_to_time(start_time)}
    # Initialize global variables
    delta_time = string_to_time(delta)
    s_b_timetag = time_to_string(start_time_float)
    previous_s_e_time = s_b_timetag
    nst = first_st_index
    prefix = "";
}

# Check if it's a file in DOS format (lines ending with \r \n)
NR==1 {if ($0 ~ "\r$") {EOL = "\r"}}

# An empty line is present after the last line of an existing subtitle
/^\r?$/ {
    if (prefix != "" && style == "bottom") {
        print prefix EOL    # Print the timetag alone after the last line
        print $0            # Print the empty line
        prefix = ""         # Remove the timetag prefix for other lines
        next
    }
}

# The index of the next existing subtitle
/^[1-9][0-9]*\r?$/ {next}

# The start and end times of the current existing subtitle
/^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} -->/ {
    # Get the start and end times of the current existing subtitle
    s_b_time = $1                     # cur subtitle begin time string
    s_e_time = $3                     # cur subtitle end   time string
    b_time = string_to_time(s_b_time) # cur subtitle begin time number
    e_time = string_to_time(s_e_time) # cur subtitle end   time number
    # Print past timetag subtitles until `b_time`
    # (the empty line preceding the subtitle (except for the first one) has already been inserted)
    insert_timetags(b_time)
    # Print the current subtitle index line and the time line
    print nst EOL; nst++ # The index had not yet been printed
    print $0             # The line "s_b_timetag --> s_e_timetag"
    # Prepare the timetag prefix for the 1st subtitle line
    prefix = s_b_time
    # Prepare next timetag subtitles
    while (b_timetag < e_time) {
        s_b_timetag = stime_add(s_b_timetag, delta)
        b_timetag  = string_to_time(s_b_timetag)
    }
    previous_s_e_time = s_e_time
    next # next line
}

{
    if (prefix == "") {
        print $0
    } else if (style == "left") {
        print prefix " " $0 # Print the 1st subtitle line prefixed by its timetag prefix
        prefix = ""         # Remove the timetag prefix for other lines
    } else if (style == "right") {
        line = $0; gsub("\r$", "", line) # Remove the trailing RETURN if any
        print line " " prefix EOL        # Print the 1st subtitle line followed by its timetag
        prefix = ""         # Remove the timetag prefix for other lines
    } else if (style == "top") {
        print prefix EOL    # Print the timetag alone on the first line
        print $0            # Print the 1st subtitle line
        prefix = ""         # Remove the timetag prefix for other lines
    } else if (style == "bottom") {
        print $0            # Print the subtitle line
        #prefix = ""        # Keep the timetag prefix until the next empty line
    }
    next
}

END {
    if (end_time != "") {
        print EOL               # Print an empty line
        # Print past timetag subtitles until the end of the movie
        insert_timetags(end_time_float)
    }
}
