#include <iostream>
#include <iomanip>
#include <cmath>


using namespace std;

int main()
{
	for (int i = 0; i < 120; i++)
	{
		double hz;
		hz = (pow(2,(i-69.0)/12.0)) * 440;
		cout <<	(int)(44100/hz + .5) << ", ";
	}
}
