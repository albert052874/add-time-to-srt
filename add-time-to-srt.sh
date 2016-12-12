#!/bin/bash

_JD_ATTS_timeStamp="Time-stamp: <2016/12/12 17:50:13 jack Jack>"
_JD_ATTS_timeStamp=$(expr "${_JD_ATTS_timeStamp}" : '.*\(<.*>\).*')

##########################################################
# Name : add-time-to-srt.sh
#
# Desc : Script to add time stamps to a subtitle file in "srt" format
# ----
#
# Usage: add-time-to-srt.sh [-v style={top, left, right, bottom}] < foo.srt > foot.srt
# -----
#
# Purpose:
# -------
# When the subtitles of a subtitle file (in .srt format) are not in synch with the movie,
# one might want to resynchronize the srt file using some tool like the "SubFix" application.
#
# 1. Save the original subtitle file:
#    mv the-movie.srt the-movie-sav.srt
#
# 2. Add timetags:
#    add-time-to-srt.sh -v end_time='01:30:00,000' the-movie-sav.srt > the-movie.srt
#
# 3. Open the movie file (with VLC)
#    - find the beginning time of the first subtitle (using the "pause" button)
#    - find the beginning time of the last subtitle (using the "pause" button)
#
# 4. Remove the file:
#    rm the-movie.srt
#
# 5. Open the original subtitle file with the "SubFix" application.
#    Fix the first and last subtitle times.
#    Save as the-movie.srt
#
# TODO:
# ----
#
# 1. Provide a set of examples
#
# 2. Provide a set of unit tests
#
# ------------------------------------------------------------------------
# [jack] 161201 Initial version: add a time stamp in each subtitle
# ------------------------------------------------------------------------

typeset _JD_ATTS_COMMAND=$0
typeset _JD_ATTS_CMD=$(basename $0)
typeset _JD_ATTS_DIR=$(dirname $0)

# 11
# 00:01:41,560 --> 00:01:45,553
# My name is Bunny.
# Bugs Bunny, Esq., to be exact.

# =>

# 11
# 00:01:41,560 --> 00:01:45,553
# My name is Bunny.
# Bugs Bunny, Esq., to be exact.
# 00:01:41,560

typeset _JD_ATTS_VARS='style delta end_time first_st_index start_time'

usage() {
    {
        echo "Usage: ${_JD_ATTS_CMD} [option] [file]"
        echo "option ::= -v style=[top | left | right | bottom]  (default: 'bottom')"
        echo "        || -v delta='hh:mm:ss,xxx'  (default: '00:00:00,100' = 1/10th sec)"
        echo "        || -v end_time='hh:mm:ss,xxx'"
        echo "        || -v first_st_index=<n>         (default: 1)"
        echo "        || -v start_time='hh:mm:ss,xxx'  (default: '00:00:00,000')"
        echo ""
        echo "Examples:"
        echo "  ${_JD_ATTS_CMD} < file.srt > file_t.srt"
        echo "  ${_JD_ATTS_CMD} -v style=left -v start_time='00:00:01,000' -v delta='00:00:00,200' -v end_time='00:00:02,000'  < /dev/null"
    } 1>&2
}

while getopts ":hv:" option; do
    case ${option} in
        h)
            usage
            exit 0
            ;;
        v)
            var_val=$OPTARG
            var=${var_val%%=*}
            if ! echo "${var_val}" | fgrep -q "="; then
                echo "${_JD_ATTS_CMD}: invalid option '-v ${var_val}'"
                echo "  The option should be '-v <var>=<val>'"
                echo "  where <var> is one of '${_JD_ATTS_VARS}'"
                echo ''
                usage
                exit 1
            fi
            if ! echo " ${_JD_ATTS_VARS} " | fgrep -q " ${var} "; then
                echo "${_JD_ATTS_CMD}: invalid var name: '${var}'"
                echo "  In the option '-v ${var_val}',"
                echo "  the var name should be one of '${_JD_ATTS_VARS}'"
                echo ''
                usage
                exit 1
            fi
            ;;
        :)
            echo "The option -$OPTARG must be followed by an argument 'var=val'"
            usage
            exit 1
            ;;
        \?)
            echo "Unknown option '$OPTARG'"
            usage
            exit 1
            ;;
    esac
done 1>&2

awk -f "${_JD_ATTS_DIR}/add-time-to-srt.awk" "$@"
