# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

module Zatir
  ##
  # Version information of Zatir
  #
  # This project adheres to {semantic versioning}[https://semver.org].
  module Version
    ##
    # The major version of Zatir
    MAJOR = 0
    ##
    # The minor version of Zatir
    MINOR = 99
    ##
    # The patch version of Zatir
    PATCH = 0
    ##
    # The version of Zatir as a String representation
    STRING = [MAJOR, MINOR, PATCH].join('.')
  end
end
