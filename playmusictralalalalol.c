/* Stringed Instrument Heroine (TM)
   Author: Larry Pyeatt
   Date: 11-1-2012
  (C) All rights reserved

   This program uses to Karplus-Strong algorithm to simulate a
   stringed instrument.  It sounds similar to a harp.  The sample
   rate for the audio samples can be adjusted using the SAMPLE_RATE
   constant.  The audio is first written to a file, then the file is
   converted to Microsoft (TM) Wave (TM) format.

   The input file is made of triplets of values.  The first value is
   an integer specifying the time at which a note is to be played, in
   milliseconds since the start of the song.  The second value is the
   MIDI number of the note to be played, and the third number is the
   relative volume of the note.  The volume is given as a floating
   point number between 0.0 and 1.0 inclusive.
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <math.h>


#define NUM_NOTES 120
#define BASE_SIZE 2756
#define SMPLS_PER_MS 441

//#define INT16_T_MAX (32767)
#include <unistd.h>


struct hstr
{
  char rifftag[4];
  uint32_t chunksize;
  char wavetag[4];
  char fmttag[4];
  uint32_t subchunk1size;
  uint16_t audioformat;
  uint16_t numchannels;
  uint32_t samplerate;
  uint32_t byterate;
  uint16_t blockalign;
  uint16_t bitspersample;
  char datatag[4];
  uint32_t subchunk2size;

};

void write_wave_header(int fd, int nsamples)
{
  static struct hstr header= {
    "RIFF",
    sizeof(struct hstr),   
    "WAVE",
    "fmt ",
    16,    // subchunk1size
    1,     // audio format
    1,     // num channels
    44100, // sample rate
    88200, // byte rate
    2,     // block alignment
    16,    // bits per sample
    "data",
    0      // sub-chunk 2 size is set at run-time
  };
  header.subchunk2size = nsamples * sizeof(int16_t);
  write(fd,&header,sizeof(header));
}
 


/*void check_write(int w, int n)
{
  if(w!=n)
    {
      perror("Error writing to wave file\n");
      exit(1);
    }
}*/ //Might need this later....




/* if note is a midi number, then the frequency is:
   hz = pow(2,(note-69.0)/12.0) * 440;
   and the array size needed is SAMPLE_RATE/Hz        
*/

/* Plucking a string is simulated by filling the array with
   random numbers between -0.5 and +0.5 
*/
void pluck(double buffer[], int size, double volume)
{
	int i;
	for(i = 0; i < size; i++)
	buffer[i] = volume * ((double)rand()/RAND_MAX - .5); //shift divide constant
}

/* The update function treats the array as a queue.  The
   first item is taken from the queue, then averaged with
   the next item.  The result of the average is added to
   the end of the queue and returned by the function as the
   next audio sample.
*/
double update(double buffer[], int size, int *position)
{
	int nextpos;
	double value;
	nextpos = (*position+1) % size;
	buffer[*position] =  value = 0.498 * (buffer[*position] + buffer[nextpos]); //shift multiply
	*position = nextpos;
	return value;
}

void scream_and_die(char progname[])
{
	fprintf(stderr,"Usage: %s input_file <tempo>\n",progname);;
	fprintf(stderr,"The input file is in Dr. Pyeatt's .notes format.\n");
	fprintf(stderr,"Tempo can be any number between 0.25 and 4.0\n");
	exit(1);
}

struct filedat
{
	int32_t time;
	int16_t note;
	int16_t vol;
};


/*  
  main opens the input and temporary files, generates the audio data
  as a stream of numbers in ASCII format, then calls convert_to_wave()
  to convert the temporary file into the output file in .wav format.
*/    
int main(int argc, char **argv)
{
	int array_size[NUM_NOTES] = {2756, 2756, 2756, 2756, 2756, 2756, 2756, 2756, 2756, 2756, 2756, 2756, 2697, 2546, 2403, 2268, 2141, 2020, 1907, 1800, 1699, 1604, 1514, 1429, 1348, 1273, 1201, 1134, 1070, 1010, 954, 900, 849, 802, 757, 714, 674, 636, 601, 567, 535, 505, 477, 450, 425, 401, 378, 357, 337, 318, 300, 283, 268, 253, 238, 225, 212, 200, 189, 179, 169, 159, 150, 142, 134, 126, 119, 113, 106, 100, 95, 89, 84, 80, 75, 71, 67, 63, 60, 56, 53, 50, 47, 45, 42, 40, 38, 35, 33, 32, 30, 28, 27, 25, 24, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 13, 12, 11, 11, 10, 9, 9, 8, 8, 7, 7, 7, 6, 6, 6};//what the hell is this array anyhow?
	int active[120] = {0};
	int notetime[120] = {0};
	int tracker = 0;
	double **notes;
	notes = (double **) malloc(sizeof(double *) * NUM_NOTES);
	int position[NUM_NOTES] = {0};
	double temp;
	int i,j;
	for (i = 0; i < NUM_NOTES; i++)
	{
		notes[i] = (double *) malloc( sizeof(double) * array_size[i]);
	} 
	FILE *input; //doing fixed point crap
	FILE *output = stdout;
	int current_time = 0;
	int current_sample = 0;
	double tempo = 1.0; //becomes long long?
	int num_samples;
	short sample;
//  double MAX = 1.0;
	  struct filedat next_note;
	  
	  if(argc < 2)
	    scream_and_die(argv[0]);
  
	  if(argc == 3)
	    {
		char *endptr;
      // try to interpret argv[2] as a float
	  tempo = strtof(argv[2],&endptr);
	      if(endptr == argv[2] || tempo < 0.25 || tempo > 4.0)
		{
		  fprintf(stderr,"Illegal tempo value.\n");
		  scream_and_die(argv[0]);
		}
	      tempo = 1.0/tempo;
	    }

	  if((input = fopen(argv[1],"r"))==NULL)
	    {
	      perror("Unable to open input file");
	      scream_and_die(argv[0]);
	    }

	  /* find time of for end of song */
	  while((fread(&next_note,sizeof(next_note),1,input)==1)&& (next_note.note != 1));
	  fseek(input,0,SEEK_SET);
  
	  num_samples = (((((tempo * next_note.time)) * 441)));// << 3) << 4) << 5) << 7) << 8; //shift multiply 1x 8x 16x 32x 128x 256x only thing thxat's been changed here so double check this

	  write_wave_header(1, num_samples);

	  srand(time(NULL));
	do 
	{
    // read the next note
 	   if(fread(&next_note,sizeof(next_note),1,input)==1)
 	     {
		next_note.time = (int)(next_note.time * tempo);
		// generate sound, one ms at a time, until we need to start
		// the next note
		while(current_time < next_note.time)
		  {
		    // generate another millsecond of sound 
		    for(i = 0; i < SMPLS_PER_MS; i++)// can't we do 0 to 441 here?
		      {
			temp = 0.0;
			// update each active string and add its output to the sum
			for(j = 0; j < tracker; j++)
			{
				if (notes[j][0] != 0)
				{
			  		temp += update(notes[active[j]], array_size[active[j]],&position[active[j]]);
					if (current_time >= notetime[j])
					{
						notetime[j] = notetime[tracker - 1];
						active[j] = active[tracker - 1];
						active[tracker - 1] = 0;
						tracker--;
						j--;
					}
				}
			}
			// write a sample to the wave file 
			sample = (int16_t)(temp) * (32766); //do a shift to multiply here?
			fwrite(&sample,sizeof(int16_t),1,output);
		      }
		    current_sample += SMPLS_PER_MS;
		    current_time++;
		  }
		if(next_note.note >= 0) // pluck the next note
		{
		  pluck(notes[next_note.note],array_size[next_note.note],next_note.vol/32767.0);//shift divide here?
		  for (i = 0; i < tracker; i++)
		  {
			if (next_note.note == active[i])
			{
				break;
			}
			
		  }
		notetime[i] = current_sample + array_size[next_note.note] * 450;
		active[i] = next_note.note;
		  if (i == tracker)
		  {
			tracker++;
		  }
		}
    	  }
	} while(!feof(input) && (next_note.note != 0));  
  
  fclose(input);
  fclose(output);
  return 0;
}
