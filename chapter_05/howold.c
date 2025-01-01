#include <stdio.h>

int howOld(int currentYear, int yearBorn)
{
  if (yearBorn <= currentYear)
  {
    return currentYear - yearBorn;
  }

  return -1;
}

int main()
{
  int age = howOld(2024, 1982);

  if (age >= 0)
  {
    printf("You are %d!\n", age);
  }
  else
  {
    printf("You haven't been born yet.");
  }
}