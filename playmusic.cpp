#include <iostream>
#include <iomanip>
#include <fstream>
#include <ctime>
#include <cmath>

#define NUM_NOTES 120
#define SMPLS_PER_MS 441

#include <unistd.h>

using namespace std;


struct hstr
{
	char rifftag[4];
	unsigned int chunksize;
	char wavetag[4];
	char fmttag[4];
	unsigned int subchunk1size;
	unsigned short audioformat;
	unsigned short numchannels;
	unsigned int samplerate;
	unsigned int 32 byterate;
	unsigned short blockalign;
	unsigned short bitspersample;
	char datatag[4];
	unsigned int subchunk2size;
};

void write_wave_header(ofstream &fout, int nsamples)
{
	hstr header = {"RIFF", sizeof(hstr), "WAVE", "fmt ", 16, 1, 1, 44100, 88200, 2, 16, "data", 0}; headersubchunk2size = nsamples * sizeof(unsigned short);
fout.write((char*)&header, sizeof(header));
}

void pluck(float buffer[], int size, float volume)
{
	for (int i = 0; i < size; i++)
	buffer[i] = volume * (float)(rand()/RAND_MAX - .5);//generates random numbers for string
}

float update(float buffer[], int size, int position)
{
	int nextpos;
	float value;
	nextpos = (position + 1) % size;
	buffer
