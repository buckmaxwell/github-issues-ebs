class AddTupleHistoryToCollaborators < ActiveRecord::Migration[5.1]
  def change
    add_column :collaborators, :tuple_history, :text
  end
end
