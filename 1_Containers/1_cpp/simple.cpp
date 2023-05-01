#include <iostream>
#include <string>

int main()
{
    while(1) {
        std::cout << "Enter string:" << std::flush;
        std::string s;
        std::getline(std::cin, s);
        if (std::cin.eof())
            break;
        std::cout << "the string was: " << s << std::endl;
    }
}