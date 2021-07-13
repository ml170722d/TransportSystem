package rs.ac.bg.etf.student.ml170722.operations;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.PackageOperations;

public class Package implements PackageOperations {
	// letter | standard | fragile
	static private final double[] startingPrice = { 10, 25, 75 };
	static private final double[] weightFactor = { 0, 1, 2 };
	static private final double[] pricePerKG = { 0, 100, 300 };

	// gas| gasoline | diesel
	static private final double[] fulePrice = { 15, 36, 32 };

	private BigDecimal calculatePackagePrice(int type, BigDecimal weight, int x1, int y1, int x2, int y2,
			BigDecimal percent) {

		double x = Math.abs(x1 - x2);
		double y = Math.abs(y1 - y2);
		BigDecimal dist = new BigDecimal(Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2)));

		double price = (startingPrice[type] + (weightFactor[type] * weight.doubleValue()) * pricePerKG[type])
				* dist.doubleValue();

		return new BigDecimal(price * (1 + percent.doubleValue() / 100));

	}

	static BigDecimal getCarConsumprionPerKM(int idV) {
		String query = "SELECT type, consumption FROM Vehicle WHERE idV=?";
		BigDecimal res = new BigDecimal(0);

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, idV);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				int type = resultSet.getInt("type");
				BigDecimal consumption = resultSet.getBigDecimal("consumption");

				res = res.add(consumption.multiply(new BigDecimal(fulePrice[type])));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return res;
	}

	private boolean checkIfCourierDriving(String username) {
		String query = "SELECT c.status FROM Courier c JOIN dbUser u ON (c.idU=u.idU) WHERE username=?";
		boolean res = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, username);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next() && resultSet.getInt("status") == 1)
				res = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return res;
	}

	private Integer getVehicleId(String username) {
		String query = "SELECT v.type FROM Vehicle v JOIN Courier c ON (c.idV=v.idV) \n"
				+ "JOIN dbUser u ON (c.idU=u.idU) WHERE username=?";
		Integer res = -1;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, username);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				res = resultSet.getInt("type");

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return res;
	}

	@Override
	public boolean acceptAnOffer(int arg0) {
		boolean success = false;
		{
			String query = "{? = call sp_acceptOffer (?)}";

			try (CallableStatement statement = DB.getInstance().getConnection().prepareCall(query)) {

				statement.registerOutParameter(1, Types.INTEGER);
				statement.setInt(2, arg0);

				statement.execute();

				if (statement.getInt(1) > 0)
					success = true;

			} catch (SQLException e) {
				// e.printStackTrace();
				System.err.println(e.getMessage());
			}
		}

		{
			String query = "SELECT p.type, p.weight, "
					+ "ds.X as x1, ds.Y as y1, dd.X as x2, dd.Y as y2, t.percentage as tax \n"
					+ "FROM Package p JOIN District ds ON (p.idSrc=ds.idD) \n"
					+ "JOIN District dd ON (p.idDest=dd.idD) JOIN TransportOffer t ON (p.idP=t.idP) \n"
					+ "WHERE t.accepted=1 AND p.idP=(SELECT idP FROM TransportOffer WHERE idTO=?)";

			try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
					PreparedStatement.RETURN_GENERATED_KEYS)) {

				statement.setInt(1, arg0);

				ResultSet resultSet = statement.executeQuery();
				BigDecimal price = null;
				if (resultSet.next())
					price = calculatePackagePrice(resultSet.getInt("type"), resultSet.getBigDecimal("weight"),
							resultSet.getInt("x1"), resultSet.getInt("y1"), resultSet.getInt("x2"),
							resultSet.getInt("y2"), resultSet.getBigDecimal("tax"));

				// update price of package
				String query2 = "UPDATE Package SET price=? WHERE idP=(SELECT idP FROM TransportOffer WHERE idTO=?)";
				try (PreparedStatement statement2 = DB.getInstance().getConnection().prepareStatement(query2,
						PreparedStatement.RETURN_GENERATED_KEYS)) {

					statement2.setBigDecimal(1, price);
					statement2.setInt(2, arg0);

					statement2.executeUpdate();

				} catch (SQLException e) {
					e.printStackTrace();
				}

			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		return success;
	}

	@Override
	public boolean changeType(int arg0, int arg1) {
		String query = "UPDATE Package SET type=? WHERE idP=?";

		boolean success = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg1);
			statement.setInt(2, arg0);

			if (statement.executeUpdate() > 0)
				success = true;

		} catch (SQLException e) {
			// e.printStackTrace();
			System.err.println(e.getMessage());
		}

		return success;
	}

	@Override
	public boolean changeWeight(int arg0, BigDecimal arg1) {
		String query = "UPDATE Package SET wieght=? WHERE idP=?";

		boolean success = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setBigDecimal(1, arg1);
			statement.setInt(2, arg0);

			if (statement.executeUpdate() > 0)
				success = true;

		} catch (SQLException e) {
			// e.printStackTrace();
			System.err.println(e.getMessage());
		}

		return success;
	}

	@Override
	public boolean deletePackage(int arg0) {
		boolean affectedRows = false;
		String query = "DELETE FROM Package WHERE idP=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				affectedRows = true;

		} catch (SQLException e) {
			// e.printStackTrace();
			System.err.println(e.getMessage());
		}

		return affectedRows;
	}

	@Override
	public int driveNextPackage(String arg0) {
		int id = -2;

		if (!checkIfCourierDriving(arg0)) {
			{
				String query = "UPDATE Courier SET status=1 \n"
						+ "WHERE idU IN (SELECT c.idU FROM Courier c join Drive d ON (c.idU=d.idU)) AND \n"
						+ "idU=(SELECT u.idU FROM dbUser u WHERE u.username=?)";

				try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
						PreparedStatement.RETURN_GENERATED_KEYS)) {

					statement.setString(1, arg0);

					statement.executeUpdate();

				} catch (SQLException e) {
					e.printStackTrace();
					return id;
				}
			}

			{
				String query = "UPDATE Package SET status=2 WHERE idP IN \n"
						+ "(SELECT d.idP FROM Drive d JOIN Package p ON (d.idP=p.idP))";

				try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
						PreparedStatement.RETURN_GENERATED_KEYS)) {

					statement.executeUpdate();

				} catch (SQLException e) {
					e.printStackTrace();
					return id;
				}
			}
		}

		{
			String query = "{ ? = call sp_getNextPackageID (?)}";

			try (CallableStatement statement = DB.getInstance().getConnection().prepareCall(query)) {

				statement.registerOutParameter(1, Types.INTEGER);
				statement.setString(2, arg0);

				statement.execute();
				id = statement.getInt(1);

			} catch (SQLException e) {
				e.printStackTrace();
				return id;
			}
		}

		{
			String query = "{ ? = call sp_updateCourier (?,?,?)}";

			try (CallableStatement statement = DB.getInstance().getConnection().prepareCall(query)) {

				statement.registerOutParameter(1, Types.INTEGER);
				statement.setString(2, arg0);
				statement.setInt(3, id);
				statement.setDouble(4, fulePrice[getVehicleId(arg0)]);

				statement.execute();

			} catch (SQLException e) {
				e.printStackTrace();
				return id;
			}
		}

		return id;
	}

	@Override
	public Date getAcceptanceTime(int arg0) {
		Date date = null;

		String query = "SELECT deliveryTime FROM Package where idP=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				date = resultSet.getDate("deliveryTime");

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return date;
	}

	@Override
	public List<Integer> getAllOffers() {

		List<Integer> list = new ArrayList<Integer>();
		String query = "SELECT idTO FROM Package";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getInt("idTO"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Pair<Integer, BigDecimal>> getAllOffersForPackage(int arg0) {
		List<Pair<Integer, BigDecimal>> list = new ArrayList<Pair<Integer, BigDecimal>>();
		String query = "SELECT idTO, percentage FROM TransportOffer WHERE accepted=0 AND idP=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				Pair<Integer, BigDecimal> tmp = new rs.ac.bg.etf.student.ml170722.operations.Pair<Integer, BigDecimal>(
						resultSet.getInt("idTO"), resultSet.getBigDecimal("percentage"));
				list.add(tmp);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Integer> getAllPackages() {

		List<Integer> list = new ArrayList<Integer>();
		String query = "SELECT idP FROM Package";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getInt("idP"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Integer> getAllPackagesWithSpecificType(int arg0) {
		List<Integer> list = new ArrayList<Integer>();
		String query = "SELECT idP FROM Package WHERE type=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getInt("idP"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public Integer getDeliveryStatus(int arg0) {
		Integer res = null;
		String query = "SELECT status FROM Package WHERE idP=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				res = resultSet.getInt("status");

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return res;
	}

	@Override
	public List<Integer> getDrive(String arg0) {
		List<Integer> list = new ArrayList<Integer>();
		String query = "SELECT p.idP FROM Drive d JOIN Courier c ON (d.idU=c.idU) "
				+ "JOIN dbUser u ON (c.idU=u.idU) JOIN Package p ON (d.idP=p.idP) \n"
				+ "WHERE u.username=? AND c.status=1 AND p.status=2";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getInt("idP"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public BigDecimal getPriceOfDelivery(int arg0) {
		BigDecimal res = null;
		String query = "SELECT price FROM Package WHERE idP=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				if (resultSet.getBigDecimal("price").floatValue() > 0)
					res = resultSet.getBigDecimal("price");

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return res;
	}

	@Override
	public int insertPackage(int arg0, int arg1, String arg2, int arg3, BigDecimal arg4) {

		int id = -1;
		String query = "INSERT INTO Package (weight, type, idDest, idSrc, status, courier, price, deliveryTime, sender) "
				+ "VALUES (?,?,?,?,0,null,null,null,(select idU from dbUser where username=?))";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setBigDecimal(1, arg4);
			statement.setInt(2, arg3);
			statement.setInt(3, arg0);
			statement.setInt(4, arg1);
			statement.setString(5, arg2);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				id = resultSet.getInt(1);

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return id;
	}

	@Override
	public int insertTransportOffer(String arg0, int arg1, BigDecimal arg2) {
		int id = -1;

		if (checkIfCourierDriving(arg0)) {
			System.err.println("Courier is driving at the moment and can't make offers");
			return id;
		}

		String query = "INSERT INTO TransportOffer (percentage, idP, idU, accepted) "
				+ "VALUES (?,?,(select u.idU from dbUser u where u.username=?),0)";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(3, arg0);
			statement.setInt(2, arg1);
			statement.setBigDecimal(1, arg2);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				id = resultSet.getInt(1);

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return id;
	}
}
