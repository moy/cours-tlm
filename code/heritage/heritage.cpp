/********************************************************************
 * Copyright (C) 2012 by Verimag                                    *
 * Initial author: Matthieu Moy                                     *
 ********************************************************************/

// Compiler avec g++ heritage.cpp -o heritage
// Executer avec ./heritage

#include <iostream>

using namespace std;

class Base {
public:
	void normalMethod() {
		cout << "Base.normalMethod() appelé" << endl;
	}

	virtual void virtualMethod() {
		cout << "Base.virtualMethod() appelé" << endl;
	}
};

class Derived : public Base {
public:
	void normalMethod() {
		cout << "Derived.normalMethod() appelé" << endl;
	}
	
	virtual void virtualMethod() {
		cout << "Derived.virtualMethod() appelé" << endl;
	}
};

int main() {
	cout << "Instanciation avec pointeurs:" << endl;
	/* 
	 * Ceci est une affectation de pointeurs, l'objet instancié
	 * est utilisé tel quel, et pD pointe dessus. Le type statique
	 * de pD est « Base * », mais son type dynamique est
	 * « Derived * »
	 */
	Base *pD = new Derived();
	pD->normalMethod();
	pD->virtualMethod();

	cout << "Instanciation sur la pile:" << endl;
	Derived d;
	/*
	 * Ici, on a une affectation de valeurs. L'objet d est « trop
	 * grand » pour rentrer dans une variable de type « Base »,
	 * l'affectation va donc faire un cast implicite de
	 * « Derived » vers « Base ». Après ceci, la variable b a un
	 * type statique et dynamique « Base », elle n'a plus rien
	 * d'un « Derived ».
	 */
	Base b = d;
	b.normalMethod();
	b.virtualMethod();
}
