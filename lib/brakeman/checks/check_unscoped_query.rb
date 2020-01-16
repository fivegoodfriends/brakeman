require 'brakeman/checks/base_check'
require "pry"

# Checks for unscoped calls to models' #find and #find_by_id methods.
class Brakeman::CheckUnscopedQuery < Brakeman::BaseCheck
  Brakeman::Checks.add_optional self

  @description = "Check for unscoped ActiveRecord queries"

  def run_check
    Brakeman.debug("Finding instances of any query #find on models with associations")

    tenant_models = [:User, :Marketplace, :Company]
    untenanted_models = active_record_models.keys.select do |name|
      next if tenant_models.include?(name)
      if model = active_record_models[name]
        [:Marketplace, :Company, :User].none? do |tenant|
          model.association?(tenant)
        end
      else
        false
      end
    end

    calls = tracker.find_call :method => [:all, :find, :find_by, :find_by!, :take, :take!, :first, :first!, :last, :last!,
                                          :second, :second!, :third, :third!, :fourth, :fourth!, :fifth, :fifth!,
                                          :forty_two, :forty_two!, :third_to_last, :third_to_last!, :second_to_last,
                                          :second_to_last!, :exists?, :any?, :many?, :none?, :one?, :first_or_create,
                                          :first_or_create!, :first_or_initialize, :find_or_create_by,
                                          :find_or_create_by!, :find_or_initialize_by, :create_or_find_by,
                                          :create_or_find_by!, :destroy_all, :delete_all, :update_all, :touch_all,
                                          :destroy_by, :delete_by, :find_each, :find_in_batches, :in_batches, :select,
                                          :reselect, :order, :reorder, :group, :limit, :offset, :joins, :left_joins,
                                          :left_outer_joins, :where, :rewhere, :preload, :extract_associated,
                                          :eager_load, :includes, :from, :lock, :readonly, :extending, :or, :having,
                                          :create_with, :distinct, :references, :none, :unscope, :optimizer_hints,
                                          :merge, :except, :only, :count, :average, :minimum, :maximum, :sum,
                                          :calculate, :annotate, :pluck, :pick, :ids],
                              :targets => associated_model_names

    calls.each do |call|
      process_result call
    end
  end

  def process_result result
    return if duplicate? result or result[:call].original_line

    add_result result

    warn :result => result,
      :warning_type => "Unscoped Query",
      :warning_code => :unscoped_query,
      :message      => msg("Unscoped query to ", msg_code("#{result[:target]}##{result[:method]}")),
      :code         => result[:call],
      :confidence   => :weak,
      :user_input   => input
  end
end
