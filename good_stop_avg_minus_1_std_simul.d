import std.algorithm;
import std.array;
import std.math;
import std.parallelism;
import std.random;
import std.range;
import std.stdio;

// The Boost License applies to the present file, as described in file ./LICENSE

// usage:
// rdmd <this_filename>
// works with at least LDC 1.30.0 - DMD v2.100.1

void main()
// https://en.wikipedia.org/wiki/Secretary_problem
{
  writeln("youpi");

  immutable LENGTH = 1000;
  immutable N_ITER = 10000;

  auto score = new double[ LENGTH * N_ITER ];
  score[] = double.nan;

  writefln( "N_ITER: %d", N_ITER );
  
  foreach (iter; parallel( iota( N_ITER ), 1000 ))
    {
      if (999 == iter % 1000) { write( iter, " / ", N_ITER, '\r' ); stdout.flush; }
      
      auto arr = iota( LENGTH ).array.randomShuffle;
      foreach (i; 0..LENGTH-1)
        {
          immutable max_before  = arr[ 0..(i+1) ].reduce!max;
          immutable max_overall = arr.reduce!max;

          immutable selected = (){

            auto x2 = arr[ i+1 ];
            foreach (x; arr[ i+1..LENGTH ])
            {
              x2 = x;
              if (x2 > max_before)
                break;
            }
            return x2;
          }();
          
          score[ i*N_ITER + iter ] = cast(double)( selected ) / cast( double )( LENGTH );
        }
    }
  writeln;

  const acc_score = score.chunks( N_ITER ).map!((c0) {
      auto c = c0.array;
      auto ndbl = cast(double)( c.length );
      auto avg = cast(double)( c.reduce!"a+b" ) / ndbl;
      auto var = reduce!((a, b) => a + pow(b - avg, 2))( 0.0, c ) / (ndbl-1.0);
      auto sd = sqrt(var);
      return avg - 1.0 * sd;
    }).array;
  
  writefln( "[%( %.4f%) ]", acc_score );
  writeln;

  immutable maxind = acc_score.maxIndex;
  writefln( "maxIndex: %d / %d  (%.2f%%)", maxind, LENGTH, 100.0 * (cast(double)( maxind )) / (cast(double)( LENGTH )) );
}
