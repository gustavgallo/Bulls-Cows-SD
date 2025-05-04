#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Player {
private:
    string name;
    vector<int> secretCode;
public:
    Player(string n) : name(n) {}

    void setSecretCode() {
        cout << name << ", digite sua sequência secreta de 4 dígitos únicos: ";
        string input;
        cin >> input;

        secretCode.clear();
        for (char c : input) {
            secretCode.push_back(c - '0');
        }
    }

    bool guess(const vector<int>& opponentCode) {
        cout << name << ", digite um palpite de 4 dígitos únicos: ";
        string input;
        cin >> input;

        vector<int> guess;
        for (char c : input) {
            guess.push_back(c - '0');
        }

        int bulls = 0, cows = 0;
        for (int i = 0; i < 4; i++) {
            if (guess[i] == opponentCode[i]) {
                bulls++;
            } else if (find(opponentCode.begin(), opponentCode.end(), guess[i]) != opponentCode.end()) {
                cows++;
            }
        }

        cout << "Bulls: " << bulls << ", Cows: " << cows << endl;
        return bulls == 4;
    }

    vector<int> getSecretCode() {
        return secretCode;
    }
};

int main() {
    Player j1("J1"), j2("J2");

    j1.setSecretCode();
    j2.setSecretCode();

    int vencedor = 0;
    while (true) {
        if (j1.guess(j2.getSecretCode()))  break; 
        if (j2.guess(j1.getSecretCode())) break; 
    cout << "BULLEYES" << endl;
    } 
}
