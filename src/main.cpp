// SRE - testing
// main.cpp
// A file to test the SRE functionality, troubleshoot, etc.

#include "sre.h"

#include <iostream>
#include <exception>

using namespace std;

int main() {
    int to_return = 0;

    try {
        // initialize the SRE
        sre_init();
        cout << "SRE initialized." << endl;

        cout << "Requesting resource..." << endl;
        uintptr_t x = sre_request_resource(10 * sizeof(int));
        cout << "Located at: " << x << endl;

        cout << "Adding reference..." << endl;
        sre_add_ref(x);

        cout << "x now has " << sre_get_rc(x) << " references" <<endl;

        while (sre_mam_contains(x) && sre_get_rc(x) > 0) {
            cout << "Freeing resource..." << endl;
            sre_free(x);
            cout << "Freed successfully" << endl;
        }

        // clean-up the SRE
        cout << "Cleaning up..." << endl;
        sre_clean();
        cout << "Done." << endl;
    } catch (exception& e) {
        cout << "Exception caught: " << e.what() << endl;
        to_return = 1;
    }

    return to_return;
}
