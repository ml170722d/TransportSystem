package rs.ac.bg.etf.student.ml170722.operations;

public class Pair<A, B> implements rs.etf.sab.operations.PackageOperations.Pair<A, B> {

	A a;
	B b;

	public Pair(A a, B b) {
		this.a = a;
		this.b = b;
	}

	@Override
	public A getFirstParam() {
		return a;
	}

	@Override
	public B getSecondParam() {
		return b;
	}

}
