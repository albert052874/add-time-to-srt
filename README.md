# add-time-to-srt

Add time stamps to a subtitle file in `srt` format

### Purpose

When the subtitles of a subtitle file (in `.srt` format) are not in synch with the movie,
one might want to resynchronize the subtitle file using some tool like the **SubFix** application.

### Description

This shell script takes as input a subtitle file (in `.srt` format) and

* inserts:
   - in each existing subtitle,
   - the precise time of this subtitle,
   - at some place in the existing subtitle, either:
     - above its first line,
     - or to the left of its first line,
     - or to the right of its first line,
     - or below its last line (by default).

* inserts:
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
