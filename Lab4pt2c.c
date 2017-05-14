#include <stdio.h>

int checksum()
{
	char buffer[4096];
	int i=0;
	int sum=0;
	printf("Enter text (ctrl-D to end); ");
	do
		buffer[i] = getchar();
	while((buffer[i] != -1) && (++i < 4096));
	buffer[i] = 0;
	printf("%s\n", buffer);
	for (i=0; buffer[i] != 0; sum+= buffer[i++]);
	return sum;
}
int main ()
{
	printf("\nThe checksum is %08X\n", checksum());
	printf("\nThe checksum is %08X\n", checksum());
	return 0;
}
