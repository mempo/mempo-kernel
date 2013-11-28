/*
 * Compare two files with checksums paths
 * 
 * sha256deep -r -l linux-image-3.2.52-grsec-good.0.2.0_01_amd64 | sort > sums
*/


#include <iostream>
#include <fstream>
#include <map>
#include <assert.h>

using namespace std;

map<string, string> parseFile(char* fileName){
  //cout << "Processing file " << fileName << endl;
  ifstream inFile(fileName);
  
  map<string, string> shaMap;
  
  while(inFile) {
    string word1, word2;
    inFile >> word1;
    inFile >> word2;
    //cout << "word1: " << word1 << endl;
    //cout << "word2: " << word2 << endl;
    shaMap.insert ( pair<string, string>(word2,word1) ); // key: filename, value: sha256sum
  }
  return shaMap;
}

bool compMap(map<string, string> fileMap1, map<string, string> fileMap2){
  std::map<string, string>::iterator it1 = fileMap1.begin();
  std::map<string, string>::iterator it2 = fileMap2.begin();
  int sameSum = 0;
  int diffSum = 0;
  ofstream samefiles;
  ofstream difffiles;
  samefiles.open("samefiles");
  difffiles.open("difffiles");
  for (it1, it2; it1 != fileMap1.end(), it2 != fileMap2.end(); ++it1, ++it2){
    //cout << it1->first << " => " << it1->second  << endl;
    if(it1->first != it2->first){
      cout << "1:" << it1->first << endl;
      cout << "2:" << it2->first << endl;
    }
    //assert(it1->first == it2->first);
    if(it1->second != it2->second){
      //cout << it1->first << endl; // << it1->second << endl << it2->second << endl << "--------------------" << endl;
      difffiles << it1->first << endl;
      diffSum++;
    }
    else{
	  samefiles << it1->first << endl;
	  sameSum++;
	}
  }
  samefiles << "--------------------" << endl << "Same files: " << sameSum << endl;
  difffiles << "--------------------" << endl << "Different files: " << diffSum << endl;
  
  samefiles.close();
  difffiles.close();
  
  //cout << "--------------------" << endl;
  cout << "Different files:\t"<< diffSum << endl;
  cout << "Same files:\t\t" << sameSum << endl;
  
  if (diffSum == 0)
    return true;
  else
    return false;
}

int main(int argc, char* argv[]) {
  if (argc != 3)
    return 0;
    
  map<string, string> fileMap1 = parseFile(argv[1]);
  map<string, string> fileMap2 = parseFile(argv[2]);
  
  bool same = compMap(fileMap1, fileMap2);
  if (same)
    cout << "All checksums are the same!" << endl;
}
