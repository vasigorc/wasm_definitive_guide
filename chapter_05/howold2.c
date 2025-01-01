int howOld(int currentYear, int yearBorn)
{
  if (yearBorn <= currentYear)
  {
    return currentYear - yearBorn;
  }

  return -1;
}