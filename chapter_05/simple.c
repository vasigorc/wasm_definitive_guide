int addArray()
{
  int retValue = 0;
  int array[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  int array_size = sizeof(array) / sizeof(int);

  for (int i = 0; i < array_size; i++)
  {
    retValue += array[i];
  }

  return retValue;
}
