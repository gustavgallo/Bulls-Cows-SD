#include <iostream>
#include <string>
using namespace std;

class player {
private:
    string name;
    string status;
    int secretCode[4] = {0, 0, 0, 0};
    bool flagZero = false;
    int wins = 0;

public:
    player() : name("Anon"), status("null") {};
    player(string name) : name(name), status("null") {};

    string getStatus() const {
        return status;
    }

    string getName() const {
        return name;
    }

    void updateStatus(const string &newStatus) {
        this->status = newStatus;
    }

    bool updateSecretCode(int a, int &pos) {
        for (int i = 0; i < 4; i++) {
            if ((a == this->secretCode[i]) && (a != 0)) {
                cout << "This number has already been chosen by you!! Try again" << endl;
                return false;
            } else if ((a == 0) && !flagZero) {
                flagZero = true;
            }
        }
        secretCode[pos] = a;
        pos++;
        return true;
    }

    int countCowsAndBulls(int* guess, int &cows, int &bulls) {
        if (status != "guessing") {
            cout << "ERROR: WRONG STATE!" << endl;
            return -1;
        }

        cows = 0;
        bulls = 0;
        bool matchedSecret[4] = {false, false, false, false};
        bool matchedGuess[4] = {false, false, false, false};

        for (int i = 0; i < 4; i++) {
            if (guess[i] == secretCode[i]) {
                bulls++;
                matchedSecret[i] = true;
                matchedGuess[i] = true;
            }
        }

        for (int i = 0; i < 4; i++) {
            if (matchedGuess[i]) continue;
            for (int j = 0; j < 4; j++) {
                if (matchedSecret[j]) continue;
                if (guess[i] == secretCode[j]) {
                    cows++;
                    matchedSecret[j] = true;
                    break;
                }
            }
        }

        return 0;
    }

    void setupSecretCode() {
        status = "setup";
        cout << this->name << " - SETUP your secret 4-digit code (digits from 0 to 7, no repeats except one zero):" << endl;
        int pos = 0;
        int aux;
        while (status == "setup") {
            if (pos < 4) {
                cout << "Digit " << pos + 1 << ": ";
                cin >> aux;
                if (cin.fail() || aux < 0 || aux > 7) {
                    cout << "Invalid input. Must be an INTEGER between 0 and 7!" << endl;
                    cin.clear();
                    cin.ignore(1000, '\n');
                } else {
                    updateSecretCode(aux, pos);
                }
            } else {
                status = "guessing";
            }
        }
    }
};

// Função para rodar o processo de setup para cada jogador
void setup(player &p) {
    p.setupSecretCode();
}

// Rodada de adivinhação
bool guess(player &guesser, player &target) {
    int guessCode[4];
    int cows = 0, bulls = 0;
    int value;

    cout << guesser.getName() << ", it's your turn to guess " << target.getName() << "'s code!" << endl;
    for (int i = 0; i < 4; i++) {
        while (true) {
            cout << "Digit " << i + 1 << ": ";
            cin >> value;
            if (cin.fail() || value < 0 || value > 7) {
                cout << "Invalid input. Must be a number between 0 and 7." << endl;
                cin.clear();
                cin.ignore(1000, '\n');
            } else {
                guessCode[i] = value;
                break;
            }
        }
    }

    target.countCowsAndBulls(guessCode, cows, bulls);

    cout << "Result: " << cows << " Cows, " << bulls << " Bulls" << endl;

    if (bulls == 4) {
        cout << guesser.getName() << " guessed the code!" << endl;
        return true;
    }

    return false;
}

// Início do jogo
void start(player &P1, player &P2) {
    setup(P1);
    setup(P2);

    bool won = false;
    while (!won) {
        won = guess(P1, P2);
        if (won) break;
        won = guess(P2, P1);
    }
}

int main() {
    cout << "Welcome to Bulls and Cows!!" << endl
         << "This is a test version made by LucasGonGo. I hope you enjoy!" << endl;

    cout << "Give a name to P1: ";
    string name1;
    cin >> name1;
    player P1(name1);

    cout << "Give a name to P2: ";
    string name2;
    cin >> name2;
    player P2(name2);

    start(P1, P2);

    return 0;
}
