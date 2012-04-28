class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :data
      t.string :aggregates

      t.timestamps
    end
  end
end
