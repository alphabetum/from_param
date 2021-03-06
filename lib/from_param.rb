class ActiveRecord::Base
  # Class Methods
  class << self
    # The column that is currently set to be used with
    # the from_param method.
    def param_column
      "param"
    end
    alias :param_column= :param_column
    
    # Allows you to set the column that will be used
    # by from_param by default.
    def set_param_column(val)
      define_attr_method :param_column, val
    end

    # Returns true if the param_column is one of the
    # currently defined columns of your table.
    def param_column?
      column_names.include?(param_column)
    end
    
    # Takes a parameter generated by to_param and
    # tried to find a matching record. If param_column
    # is set and exists, uses that as the finder, otherwise
    # uses the id such as in the default Rails to_param.
    def from_param(*options)
      if param_column?
        send "find_by_#{param_column}", *options
      else
        find(*options)        
      end
    end
  end
  
  # Calls param_column? on the class
  def param_column?
    self.class.param_column?
  end
  
  # Calls param_column on the class
  def param_column
    self.class.param_column
  end
  
  # Automatically called before saving, sets
  # the param_column to the current to_param
  def set_param
    send "#{param_column}=", to_param if param_column?
  end
end

class ActionController::Base
  # Use as a before_filter.
  def get_from_param
    instance_variable_set(
      "@#{self.controller_name.singularize}", 
      self.controller_name.classify.constantize.from_param(params[:id])
    )
  end
end