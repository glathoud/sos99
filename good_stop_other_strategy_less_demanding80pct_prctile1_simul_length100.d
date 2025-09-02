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
{
  writeln("youpi");

  immutable LENGTH = 100;
  immutable N_ITER = 100000;

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
              if (cast(double)( x2 ) > (0.80 * cast(double)( max_before )))
                break;
            }
            return x2;
          }();
          
          score[ i*N_ITER + iter ] = cast(double)( selected ) / cast( double )( LENGTH ); // uniform distribution of scores from worst (0.0) to best (1.0)
        }
    }
  writeln;

  const acc_score = score.chunks( N_ITER ).map!((c0) {
      auto c = c0.array.dup.sort.array;
      return c[ cast(size_t)( round( 0.01 * cast( double )( LENGTH )) )];
    }).array;

  writeln( "acc_score:" );
  writefln( "[%( %.4f%) ]", acc_score );
  writeln;

  const acc_score_top_median = score.chunks( N_ITER ).map!((c0) {
      auto c = c0.array.dup.sort.array;
      return c[ cast(size_t)( round( (0.01 + 0.99/2.0) * cast( double )( LENGTH )) )];
    }).array;

  writeln( "acc_score_top_median:" );
  writefln( "[%( %.4f%) ]", acc_score_top_median );
  writeln;

  immutable maxind = acc_score.maxIndex;  immutable maxval = acc_score[ maxind ];
  writefln( "maxIndex: %d / %d  (%.2f%%) - maxval: %.4f", maxind, LENGTH, 100.0 * (cast(double)( maxind )) / (cast(double)( LENGTH )), maxval );

  static if (false)
    {
      writeln;
      writeln( "raw data for that maxIndex chunk:" );
      writefln( "[%( %.7f%)]", score[maxind*N_ITER..(maxind+1)*N_ITER] ); // not quite Gaussian => cannot use avg/std analysis
    }
}
