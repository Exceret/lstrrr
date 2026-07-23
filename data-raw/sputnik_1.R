## code to prepare `sputnik_1` dataset goes here

km_per_mile <- 1.609344

source_urls <- c(
  nasa_history = "https://www.nasa.gov/wp-content/uploads/static/history/sputnik.html",
  nasa_siddiqi = "https://www.nasa.gov/history/sputnik/siddiqi.html",
  usaf_museum = "https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/197681/sputnik-i/",
  state_department = "https://history.state.gov/milestones/1953-1960/sputnik",
  wikipedia = "https://en.wikipedia.org/wiki/Sputnik_1"
)

sputnik_1 <- list(
  meta = list(
    dataset = "sputnik_1",
    title = "Sputnik 1 mission and spacecraft information",
    description = paste(
      "A nested list collecting structured historical, technical, orbital,",
      "and cultural information about Sputnik 1, the first artificial Earth satellite."
    ),
    language = c("English", "Chinese annotations"),
    created = as.Date("2026-07-22"),
    sources = source_urls,
    note = list(
      traversal_note = paste(
        "This object intentionally contains data frames, NULL values, empty lists,",
        "named branches, unnamed branches, dates, POSIXct values, numeric vectors,",
        "character vectors, and deeply nested lists for testing recursive list mapping."
      ),
      data_frame_policy = "Data frames should be treated as leaf values by lstrrr traversal."
    )
  ),

  identity = list(
    names = list(
      common = "Sputnik 1",
      russian = "Спутник-1",
      translated = c("Satellite 1", "Fellow Traveler 1"),
      development_names = c(
        "PS-1",
        "Prosteishiy Sputnik-1",
        "Object PS",
        "Elementary Satellite-1"
      )
    ),
    classification = list(
      object_type = "Artificial Earth satellite",
      mission_type = "Technology demonstration",
      orbit_class = "Low Earth orbit",
      historical_firsts = c(
        "First artificial Earth satellite",
        "First human-made satellite successfully placed into Earth orbit",
        "Beginning symbol of the Space Age"
      )
    ),
    identifiers = list(
      cospar_id = "1957-001B",
      harvard_designation = "1957 Alpha 2",
      satcat = 2L
    ),
    program = list(
      program_name = "Sputnik program",
      country = "Soviet Union",
      operator = "OKB-1",
      chief_designer_commonly_associated = "Sergei Korolev"
    )
  ),

  launch = list(
    datetime = list(
      utc = as.POSIXct("1957-10-04 19:28:34", tz = "UTC"),
      date_utc = as.Date("1957-10-04"),
      date_at_launch_site = as.Date("1957-10-05"),
      note = "The launch occurred on 4 October 1957 UTC; locally at Baikonur it was already 5 October."
    ),
    site = list(
      name = "Baikonur Cosmodrome Site 1/5",
      historical_name = "NIIP-5 / Tyuratam range",
      present_country = "Kazakhstan",
      launch_pad_significance = "Later famous as the Gagarin's Start launch pad."
    ),
    launch_vehicle = list(
      name = "Sputnik-PS",
      designation = "8K71PS",
      family = "R-7",
      derived_from = "R-7 Semyorka intercontinental ballistic missile",
      role = "Launch vehicle for placing PS-1 into orbit"
    ),
    participants = list(
      launch_contractor = "OKB-1",
      state = "Union of Soviet Socialist Republics",
      related_international_context = "International Geophysical Year, 1957-1958"
    )
  ),

  spacecraft = list(
    physical = list(
      shape = "Polished pressurized sphere",
      diameter_cm = 58.5,
      diameter_m = 0.585,
      mass_kg = 83.6,
      mass_lb = 183.9,
      exterior = list(
        finish = "Highly polished metal",
        purpose = c(
          "Thermal control",
          "Optical visibility",
          "Simplified spherical aerodynamic and orbital analysis"
        )
      )
    ),

    internal_systems = list(
      atmosphere = list(
        pressurized = TRUE,
        gas = "nitrogen",
        pressure_atm = 1.3
      ),
      power = list(
        battery_type = "silver-zinc",
        battery_count = 3L,
        power_source_mass_kg = 51.0,
        expected_operation = "roughly two to three weeks",
        signal_end_date = as.Date("1957-10-26")
      ),
      radio = list(
        transmitters = "two D-200 radio transmitters",
        frequencies_mhz = c(20.005, 40.002),
        wavelengths_m = round(299.792458 / c(20.005, 40.002), 3),
        pulse_duration_s = c(min = 0.2, max = 0.6),
        common_description = "beep-beep radio pulses",
        approximate_transmitter_power_w = 1
      ),
      thermal_control = list(
        system = "DTK-34 temperature regulation system",
        components = c(
          "ventilation system",
          "temperature transmitter",
          "pressure transmitter"
        )
      )
    ),

    antennas = data.frame(
      antenna_pair = c("pair_1", "pair_2"),
      count = c(2L, 2L),
      length_m = c(2.4, 2.9),
      purpose = c(
        "radio pulse transmission",
        "radio pulse transmission"
      ),
      stringsAsFactors = FALSE
    )
  ),

  orbit = list(
    summary = list(
      reference_body = "Earth",
      regime = "Low Earth orbit",
      orbit_shape = "elliptical",
      period_min = 96.2,
      inclination_deg = 65.1,
      approximate_orbit_time_description = "about 98 minutes according to NASA historical summary"
    ),

    canonical_values = list(
      perigee_km = 215,
      apogee_km = 939,
      inclination_deg = 65.1,
      period_min = 96.2,
      decay_date = as.Date("1958-01-04"),
      completed_orbits = 1440L
    ),

    source_values = data.frame(
      source = c("Wikipedia", "USAF Museum"),
      perigee_km = c(215, round(142 * km_per_mile, 1)),
      apogee_km = c(939, round(588 * km_per_mile, 1)),
      period_min = c(96.20, 96.17),
      inclination_deg = c(65.10, 65.60),
      stringsAsFactors = FALSE
    ),

    lifetime = list(
      launch_date = as.Date("1957-10-04"),
      last_contact_date = as.Date("1957-10-26"),
      reentry_date = as.Date("1958-01-04"),
      days_in_orbit = as.integer(as.Date("1958-01-04") - as.Date("1957-10-04")),
      radio_signal_duration_days_reported = 21L,
      disposal = "Atmospheric reentry and burn-up"
    )
  ),

  mission_objectives = list(
    scientific = c(
      "Test the method of placing an artificial satellite into Earth orbit",
      "Estimate upper-atmosphere density from orbital lifetime",
      "Test radio and optical orbital tracking methods",
      "Study radio-wave propagation through the atmosphere",
      "Verify pressurization principles for future satellites"
    ),
    engineering = c(
      "Demonstrate launch vehicle capability",
      "Demonstrate a simple reliable satellite bus",
      "Demonstrate battery-powered radio transmission from orbit"
    ),
    observations = data.frame(
      observable = c("radio beeps", "orbital decay", "visual tracking"),
      measured_or_inferred = c(
        "radio propagation and tracking",
        "atmospheric drag and density inference",
        "orbital position and public visibility"
      ),
      instrument_or_method = c(
        "shortwave radio receiver",
        "ground-based orbit determination",
        "optical observation"
      ),
      stringsAsFactors = FALSE
    )
  ),

  chronology = data.frame(
    date = as.Date(c(
      "1952-01-01",
      "1954-12-17",
      "1957-01-25",
      "1957-02-15",
      "1957-10-04",
      "1957-10-26",
      "1958-01-04",
      "1958-01-31"
    )),
    event = c(
      "International scientific planning for artificial satellites gains momentum.",
      "Sergei Korolev proposes a satellite development plan.",
      "Initial PS-1 design details approved.",
      "USSR Council of Ministers approves the simplified satellite plan.",
      "Sputnik 1 is launched into Earth orbit.",
      "Radio contact ends after battery depletion.",
      "Sputnik 1 reenters Earth's atmosphere.",
      "Explorer 1 becomes the first successful U.S. satellite."
    ),
    category = c(
      "context",
      "proposal",
      "design",
      "approval",
      "launch",
      "operations",
      "reentry",
      "aftermath"
    ),
    stringsAsFactors = FALSE
  ),

  historical_context = list(
    international_geophysical_year = list(
      period = c(
        start = as.Date("1957-07-01"),
        end = as.Date("1958-12-31")
      ),
      role = paste(
        "The International Geophysical Year encouraged scientific satellite",
        "projects by both the United States and the Soviet Union."
      )
    ),

    cold_war_impact = list(
      themes = c(
        "Sputnik crisis",
        "Space Race",
        "arms race",
        "missile gap anxiety",
        "science and engineering education investment"
      ),
      united_states_response = list(
        explorer_1_launch = as.Date("1958-01-31"),
        nasa_created = 1958L,
        naca_to_nasa = TRUE
      ),
      summary = paste(
        "Sputnik 1's success shocked the United States and became a highly visible",
        "symbol of Soviet technological capability during the Cold War."
      )
    )
  ),

  related_spacecraft = data.frame(
    name = c("Sputnik 2", "Explorer 1", "Sputnik 3"),
    country = c("Soviet Union", "United States", "Soviet Union"),
    launch_date = as.Date(c("1957-11-03", "1958-01-31", "1958-05-15")),
    significance = c(
      "Carried Laika, the first animal to orbit Earth",
      "First successful U.S. satellite",
      "Larger Soviet scientific satellite"
    ),
    stringsAsFactors = FALSE
  ),

  source_notes = list(
    primary_sources = data.frame(
      short_name = c(
        "NASA History",
        "NASA Siddiqi",
        "USAF Museum",
        "U.S. State Department",
        "Wikipedia"
      ),
      url = unname(source_urls[c(
        "nasa_history",
        "nasa_siddiqi",
        "usaf_museum",
        "state_department",
        "wikipedia"
      )]),
      used_for = c(
        "General summary, size, mass, historical significance",
        "Design details, objectives, transmitters, antennas, internal systems",
        "Technical notes and alternate orbital parameters",
        "Cold War and U.S. policy impact",
        "Identifiers, launch metadata, orbit and mission summary"
      ),
      stringsAsFactors = FALSE
    ),
    orbital_parameter_note = paste(
      "Different references report slightly different initial orbital parameters.",
      "For testing and transparency, source-specific values are preserved in",
      "`orbit$source_values`."
    )
  ),

  test_branches = list(
    named_branch = list(
      a = "named leaf",
      b = list(
        c = "deep named leaf",
        d = list(
          e = 1957L
        )
      )
    ),
    unnamed_branch = list(
      "first unnamed leaf",
      list(
        "nested unnamed leaf",
        list(
          flag = TRUE,
          score = 0.999
        )
      )
    ),
    null_leaf = NULL,
    empty_branch = list()
  )
)

usethis::use_data(sputnik_1, overwrite = TRUE)
