# add-time-to-srt

### Name

`add-time-to-srt.sh` - Add time stamps to a subtitle file in `srt` format

### Purpose

When the subtitles of a subtitle file (in `.srt` format) are not in synch with the movie,
one might want to resynchronize the subtitle file using some tool like the **SubFix** application.

### Synopsis

~~~sh
    add-time-to-srt.sh [option] [file]
~~~

### Description

This shell script takes as input a subtitle file (in `.srt` format) and writes it on the standard output with some additions.

* It inserts:
   - in each existing subtitle,
   - the precise beginning time of this subtitle,
   - at some place in the existing subtitle, either:
     - above its first line,
     - or to the left of its first line,
     - or to the right of its first line,
     - or below its last line (by default).

* It inserts:
   - a new subtitle with the current time,
   - every 1/10 s (by default),
   - between existing subtitles.


### Global usage

* Save the original subtitle file:

~~~sh
    mv the-movie.srt the-movie-sav.srt
~~~

* Add timetags:

~~~sh
    add-time-to-srt.sh -v end_time='01:30:00,000' the-movie-sav.srt > the-movie.srt
~~~

* Open the movie file (with **VLC**, for example)

   - find the beginning time of the first subtitle (using the **pause** button)  
   - find the beginning time of the last subtitle (using the **pause** button)

* Remove the file with superfluous subtitles:

~~~sh
    rm the-movie.srt
~~~

* Launch the **SubFix** application.
   - Open the original subtitle file `the-movie-sav.srt`.
   - Fix the first and last subtitle times.
   - Save the fixed subtitle file:  
     menu **File > Save as...** `the-movie.srt`

### Script options

* `-v style=[top | left | right | bottom]`  (default: 'bottom')

 Choose the place to insert its timetag in an existing subtitle:
     - `top`: above its first line,
     - `left`: to the left of its first line,
     - `right`: to the right of its first line,
     - `bottom`: below its last line (by default).

* `-v delta='hh:mm:ss,xxx'`  (default: '00:00:00,100' = 1/10th sec)

 Choose the delay between new pure timetag subtitles.

* `-v end_time='hh:mm:ss,xxx'`

 When this option is present, insert new pure timetag subtitles after the last existing subtitle until the specified `end_time`.

* `-v first_st_index=<n>`        (default: 1)

 Start the numbering of subtitles from the specified index.

* `-v start_time='hh:mm:ss,xxx'`  (default: '00:00:00,000')

 Start the new timetags from the specified time.

### Examples:

* Minimal command

~~~sh
add-time-to-srt.sh < file.srt > file_t.srt
~~~

* Print just five timetags with no input

~~~sh
add-time-to-srt.sh -v style=left -v start_time='00:00:01,000' \
  -v delta='00:00:00,200' -v end_time='00:00:02,000'  < /dev/null
~~~
