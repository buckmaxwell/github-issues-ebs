class CreateCollaborators < ActiveRecord::Migration[5.1]
  def change
    create_table :collaborators do |t|
      t.text :login
      t.text :history

      t.timestamps
    end
  end
end
