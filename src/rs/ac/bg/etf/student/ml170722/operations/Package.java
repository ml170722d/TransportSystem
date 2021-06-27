package rs.ac.bg.etf.student.ml170722.operations;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

import rs.etf.sab.operations.PackageOperations;

public class Package implements PackageOperations {

	@Override
	public boolean acceptAnOffer(int arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean changeType(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean changeWeight(int arg0, BigDecimal arg1) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean deletePackage(int arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public int driveNextPackage(String arg0) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public Date getAcceptanceTime(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Integer> getAllOffers() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Pair<Integer, BigDecimal>> getAllOffersForPackage(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Integer> getAllPackages() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Integer> getAllPackagesWithSpecificType(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Integer getDeliveryStatus(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Integer> getDrive(String arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public BigDecimal getPriceOfDelivery(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int insertPackage(int arg0, int arg1, String arg2, int arg3, BigDecimal arg4) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int insertTransportOffer(String arg0, int arg1, BigDecimal arg2) {
		// TODO Auto-generated method stub
		return 0;
	}

}
