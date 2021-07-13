package rs.ac.bg.etf.student.ml170722.operations;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.CourierOperations;

public class Courier implements CourierOperations {

	@Override
	public boolean deleteCourier(String arg0) {

		String query = "DELETE FROM Courier WHERE idU = (SELECT idU FROM dbUser WHERE username=?) AND status IS NOT NULL";
		boolean affectedRows = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);

			if (statement.executeUpdate() > 0)
				affectedRows = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return affectedRows;
	}

	@Override
	public List<String> getAllCouriers() {

		List<String> list = new ArrayList<String>();
		String query = "SELECT username FROM dbUser WHERE idU = (SELECT idU FROM Courier WHERE status IS NOT NULL)";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getString("username"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public BigDecimal getAverageCourierProfit(int arg0) {

		BigDecimal avgDist = new BigDecimal(0);
		BigDecimal result = new BigDecimal(0);
		BigDecimal avgConsumption = new BigDecimal(0);

		{
			String query = "select p.idP, c.idV \n"
					+ "from Courier c join Drive d on (c.idU=d.idU) join Package p on (d.idP=p.idP) \n"
					+ "where c.deliveredPackages>=0 and p.status=3";

			try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
					PreparedStatement.RETURN_GENERATED_KEYS)) {

				ResultSet resultSet = statement.executeQuery();
				int i = 0;
				while (resultSet.next()) {
					String query2 = "{ call sp_distance (?,?) }";

					CallableStatement statement2 = DB.getInstance().getConnection().prepareCall(query2);

					statement2.setInt(1, resultSet.getInt("idP"));
					statement2.registerOutParameter(2, Types.DECIMAL);

					statement2.execute();
					avgDist = avgDist.add(statement2.getBigDecimal(2));
					avgConsumption = avgConsumption.add(Package.getCarConsumprionPerKM(resultSet.getInt("idV")));
					i++;
				}

				avgDist = avgDist.divide(new BigDecimal(i));
				avgConsumption = avgConsumption.divide(new BigDecimal(i));

			} catch (SQLException e) {
				e.printStackTrace();
				return result;
			}
		}

		String query = "SELECT SUM(profit) as profit, SUM(deliveredPackages) as delivered \n"
				+ "FROM Courier WHERE deliveredPackages>=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				BigDecimal gain = resultSet.getBigDecimal("profit");
				BigDecimal loss = avgDist.multiply(avgConsumption).multiply(resultSet.getBigDecimal("delivered"));
				result = gain.subtract(loss);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return result;
	}

	@Override
	public List<String> getCouriersWithStatus(int arg0) {

		List<String> list = new ArrayList<String>();
		String query = "SELECT username FROM dbUser WHERE idU = (SELECT idU FROM Courier) AND status=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getString("username"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public boolean insertCourier(String arg0, String arg1) {

		boolean success = false;
		String query = "{? = call sp_newCourier (?,?)}";

		try (CallableStatement statement = DB.getInstance().getConnection().prepareCall(query)) {

			statement.registerOutParameter(1, Types.INTEGER);
			statement.setString(2, arg0);
			statement.setString(3, arg1);

			statement.execute();
			if (statement.getInt(1) > 0)
				success = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return success;
	}

}
