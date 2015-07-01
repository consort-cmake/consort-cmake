#include <iostream>
#include <boost/date_time.hpp>

int main()
{
	std::cout << boost::posix_time::second_clock::universal_time() << " UTC\n";
	return 0;
}
