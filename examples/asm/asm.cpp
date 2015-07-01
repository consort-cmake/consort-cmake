#include <iostream>

extern "C" { int is_asm_enabled(); }

int main()
{
	if(is_asm_enabled())
	{
		std::cout << "Consort ASM is enabled\n";
		return 0;
	}
	else
	{
		std::cout << "Consort ASM is disabled\n";
		return 1;
	}
}
