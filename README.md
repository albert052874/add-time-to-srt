# add-time-to-srt

Add time stamps to a subtitle file in "srt" format

When the subtitles of a subtitle file (in .srt format) are not in synch with the movie,
one might want to resynchronize the srt file using some tool like the "SubFix" application.

1. Save the original subtitle file:

    mv the-movie.srt the-movie-sav.srt

2. Add timetags:

    add-time-to-srt.sh -v end_time='01:30:00,000' the-movie-sav.srt > the-movie.srt

3. Open the movie file (with VLC)

   - find the beginning time of the first subtitle (using the "pause" button)  
   - find the beginning time of the last subtitle (using the "pause" button)

4. Remove the file:

    rm the-movie.srt

5. Open the original subtitle file with the "SubFix" application.

   Fix the first and last subtitle times.  
   Save as... the-movie.srt
