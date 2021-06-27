package rs.ac.bg.etf.student.ml170722.operations;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.VehicleOperations;

public class Vehicle implements VehicleOperations {

	@Override
	public boolean changeConsumption(String arg0, BigDecimal arg1) {
		String query = "UPDATE Vehicle SET consumption=? WHERE licencePlate=?";

		boolean success = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setDouble(1, arg1.doubleValue());
			statement.setString(2, arg0);

			if (statement.executeUpdate() > 0)
				success = true;

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return success;
	}

	@Override
	public boolean changeFuelType(String arg0, int arg1) {
		String query = "UPDATE Vehicle SET type=? WHERE licencePlate=?";

		boolean success = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg1);
			statement.setString(2, arg0);

			if (statement.executeUpdate() > 0)
				success = true;

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return success;
	}

	@Override
	public int deleteVehicles(String... arg0) {
		String query = "DELETE FROM Vehicle WHERE licencePlate=?";

		int affectedRows = 0;

		for (String licencPlate : arg0) {
			try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
					PreparedStatement.RETURN_GENERATED_KEYS)) {

				statement.setString(1, licencPlate);
				affectedRows += statement.executeUpdate();

			} catch (SQLException e) {
				// e.printStackTrace();
			}
		}

		return affectedRows;
	}

	@Override
	public List<String> getAllVehichles() {
		List<String> list = new ArrayList<String>();

		try (Statement statement = DB.getInstance().getConnection().createStatement()) {

			String query = "SELECT licencePlate FROM Vehicle";

			ResultSet resultSet = statement.executeQuery(query);
			while (resultSet.next()) {
				list.add(resultSet.getString("licencePlate"));
			}

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return list;
	}

	@Override
	public boolean insertVehicle(String arg0, int arg1, BigDecimal arg2) {
		String query = "INSERT INTO Vehicle (type, consumption, licencePlate) VALUES (?, ?, ?)";
		boolean success = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg1);
			statement.setDouble(2, arg2.doubleValue());
			statement.setString(3, arg0);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				success = true;

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return success;
	}

}
