/// Extended profile data for a professional (description, details, verified services).
class ProfessionalProfileData {
  final String from;
  final String qualifications;
  final String avgResponseTime;
  final String description;
  final List<String> verifiedServices;

  const ProfessionalProfileData({
    required this.from,
    required this.qualifications,
    required this.avgResponseTime,
    required this.description,
    required this.verifiedServices,
  });

  static ProfessionalProfileData getForProfessional(String id) {
    final data = _profileData[id];
    if (data != null) return data;

    final prefix = id.split('-').first;
    return _categoryFallbackData[prefix] ?? _profileData['plumber-1']!;
  }

  static const _categoryFallbackData = {
    'ac': ProfessionalProfileData(
      from: 'Colombo',
      qualifications: 'NVQ-L3 Refrigeration',
      avgResponseTime: '4-9 Minutes',
      description:
          'Certified AC technician for diagnostics, gas charging, and routine servicing. Focused on quick and reliable cooling solutions for homes and offices.',
      verifiedServices: [
        'AC Repair',
        'Gas Refill',
        'Compressor Checks',
        'Routine Maintenance',
      ],
    ),
    'elv': ProfessionalProfileData(
      from: 'Colombo',
      qualifications: 'ELV Systems Certified',
      avgResponseTime: '5-10 Minutes',
      description:
          'Experienced ELV specialist for CCTV, access control, and low-voltage troubleshooting. Delivers neat installation and dependable system performance.',
      verifiedServices: [
        'CCTV Setup',
        'Access Control',
        'Alarm Systems',
        'Low Voltage Repairs',
      ],
    ),
  };

  static const _profileData = {
    // Plumbers
    'plumber-1': ProfessionalProfileData(
      from: 'Battaramulla',
      qualifications: 'NVQ-L3',
      avgResponseTime: '1-5 Minutes',
      description:
          "I'm Saman - your trusted plumbing expert with over 12 years of hands-on experience. Specializing in emergency leak repairs, pipe installations, and bathroom plumbing.",
      verifiedServices: [
        'Pipe Installation & Repair',
        'Leak Detection & Fixing',
        'Drain Unblocking',
        'Emergency Repairs',
      ],
    ),
    'plumber-2': ProfessionalProfileData(
      from: 'Nugegoda',
      qualifications: 'NVQ-L3, City & Guilds',
      avgResponseTime: '5-10 Minutes',
      description:
          "Hi, I'm Sunil with 8+ years in plumbing. I handle water heaters, pipe repairs, and general plumbing. Quality work at fair prices.",
      verifiedServices: [
        'Water Heater Repair',
        'Pipe Installation',
        'Leak Detection',
        'Drain Cleaning',
      ],
    ),
    'plumber-3': ProfessionalProfileData(
      from: 'Colombo 05',
      qualifications: 'NVQ-L2',
      avgResponseTime: '3-7 Minutes',
      description:
          "Kamala here - experienced plumber specializing in kitchen and bathroom work. Clean, professional, and reliable.",
      verifiedServices: [
        'Kitchen Plumbing',
        'Bathroom Repairs',
        'Pipe Installation',
        'Emergency Repairs',
      ],
    ),
    'plumber-4': ProfessionalProfileData(
      from: 'Maharagama',
      qualifications: 'NVQ-L3, Diploma',
      avgResponseTime: '2-6 Minutes',
      description:
          "Rohan - 10 years of plumbing experience. I tackle everything from small leaks to major installations. Honest and punctual.",
      verifiedServices: [
        'Leak Detection & Fixing',
        'Pipe Replacement',
        'Toilet Repairs',
        'Emergency Repairs',
      ],
    ),
    'plumber-5': ProfessionalProfileData(
      from: 'Dehiwala',
      qualifications: 'NVQ-L3',
      avgResponseTime: '4-8 Minutes',
      description:
          "Nimal - your local plumbing specialist. Over 7 years in the trade. Same-day service for emergencies and competitive rates.",
      verifiedServices: [
        'Emergency Repairs',
        'Pipe Installation',
        'Drain Unblocking',
        'Water System Repair',
      ],
    ),
    // Electricians
    'electrician-1': ProfessionalProfileData(
      from: 'Kotte',
      qualifications: 'C&G Level 3, Licensed',
      avgResponseTime: '2-5 Minutes',
      description:
          "Dilshan - licensed electrician with 10+ years. Wiring, outlets, lighting, and electrical repairs. Safe and reliable service.",
      verifiedServices: [
        'Wiring & Rewiring',
        'Outlets & Switches',
        'Lighting Installation',
        'Electrical Repairs',
      ],
    ),
    'electrician-2': ProfessionalProfileData(
      from: 'Malabe',
      qualifications: 'NVQ-L3',
      avgResponseTime: '5-8 Minutes',
      description:
          "Nirosha - qualified electrician. Residential and commercial work. Panel upgrades, fault finding, and installations.",
      verifiedServices: [
        'Panel Upgrades',
        'Fault Finding',
        'Outlet Installation',
        'Safety Inspections',
      ],
    ),
    'electrician-3': ProfessionalProfileData(
      from: 'Kohuwala',
      qualifications: 'C&G, Licensed',
      avgResponseTime: '3-6 Minutes',
      description:
          "Chandima - expert in lighting design and electrical installations. Clean work and clear explanations.",
      verifiedServices: [
        'Lighting Design',
        'Smart Home Wiring',
        'Electrical Installation',
        'Repairs',
      ],
    ),
    'electrician-4': ProfessionalProfileData(
      from: 'Kiribathgoda',
      qualifications: 'NVQ-L2',
      avgResponseTime: '6-12 Minutes',
      description:
          "Tharanga - 6 years experience. General electrical work, repairs, and installations at fair prices.",
      verifiedServices: [
        'General Repairs',
        'Wiring',
        'Outlet Fixes',
        'Electrical Maintenance',
      ],
    ),
    'electrician-5': ProfessionalProfileData(
      from: 'Nawala',
      qualifications: 'NVQ-L3',
      avgResponseTime: '4-9 Minutes',
      description:
          "Manjula - reliable electrician for homes and small businesses. Quality work, honest pricing.",
      verifiedServices: [
        'Residential Wiring',
        'Lighting',
        'Repairs',
        'Safety Checks',
      ],
    ),
    // Gardeners
    'gardener-1': ProfessionalProfileData(
      from: 'Rajagiriya',
      qualifications: 'Landscaping Diploma',
      avgResponseTime: '5-10 Minutes',
      description:
          "Bandula - 15 years in lawn care and landscaping. Lawn maintenance, pruning, and garden design.",
      verifiedServices: [
        'Lawn Care',
        'Pruning',
        'Landscaping',
        'Garden Maintenance',
      ],
    ),
    'gardener-2': ProfessionalProfileData(
      from: 'Borella',
      qualifications: 'Horticulture Cert',
      avgResponseTime: '8-15 Minutes',
      description:
          "Sunethra - passionate gardener. Specializing in flowering plants, organic gardening, and lawn care.",
      verifiedServices: [
        'Flower Beds',
        'Organic Gardening',
        'Lawn Care',
        'Plant Care',
      ],
    ),
    'gardener-3': ProfessionalProfileData(
      from: 'Havelock Town',
      qualifications: 'Landscaping NVQ',
      avgResponseTime: '3-7 Minutes',
      description:
          "Ajith - professional landscaper. Lawn mowing, hedge trimming, and full garden maintenance.",
      verifiedServices: [
        'Lawn Mowing',
        'Hedge Trimming',
        'Landscaping',
        'Garden Design',
      ],
    ),
    'gardener-4': ProfessionalProfileData(
      from: 'Wellawatte',
      qualifications: 'Gardening Cert',
      avgResponseTime: '10-18 Minutes',
      description:
          "Ruwani - experienced gardener. Regular maintenance, weeding, and plant care for beautiful gardens.",
      verifiedServices: [
        'Garden Maintenance',
        'Weeding',
        'Plant Care',
        'Lawn Care',
      ],
    ),
    'gardener-5': ProfessionalProfileData(
      from: 'Mount Lavinia',
      qualifications: 'Horticulture',
      avgResponseTime: '12-20 Minutes',
      description:
          "Thusitha - lawn and garden specialist. Pruning, fertilizing, and seasonal garden care.",
      verifiedServices: [
        'Lawn Care',
        'Pruning',
        'Fertilizing',
        'Seasonal Care',
      ],
    ),
    // Carpenters
    'carpenter-1': ProfessionalProfileData(
      from: 'Colombo 03',
      qualifications: 'NVQ-L3 Carpentry',
      avgResponseTime: '4-8 Minutes',
      description:
          "Asela - skilled carpenter with 12 years experience. Furniture repair, custom woodwork, and installations.",
      verifiedServices: [
        'Furniture Repair',
        'Custom Woodwork',
        'Installations',
        'Cabinetry',
      ],
    ),
    'carpenter-2': ProfessionalProfileData(
      from: 'Pamankada',
      qualifications: 'C&G Carpentry',
      avgResponseTime: '6-12 Minutes',
      description:
          "Indika - professional carpenter. Doors, windows, furniture, and general carpentry. Quality craftsmanship.",
      verifiedServices: [
        'Doors & Windows',
        'Furniture',
        'General Carpentry',
        'Repairs',
      ],
    ),
    'carpenter-3': ProfessionalProfileData(
      from: 'Narahenpita',
      qualifications: 'NVQ-L2',
      avgResponseTime: '5-10 Minutes',
      description:
          "Nadeeka - experienced carpenter. Furniture assembly, repairs, and custom pieces. Reliable and skilled.",
      verifiedServices: [
        'Furniture Assembly',
        'Repairs',
        'Custom Pieces',
        'Installations',
      ],
    ),
    'carpenter-4': ProfessionalProfileData(
      from: 'Bambalapitiya',
      qualifications: 'NVQ-L3',
      avgResponseTime: '8-14 Minutes',
      description:
          "Kumara - 9 years carpentry experience. Doors, cabinets, and woodwork. Clean, precise work.",
      verifiedServices: ['Cabinet Making', 'Doors', 'Woodwork', 'Repairs'],
    ),
    'carpenter-5': ProfessionalProfileData(
      from: 'Horton Place',
      qualifications: 'Carpentry Diploma',
      avgResponseTime: '10-16 Minutes',
      description:
          "Chamari - furniture and repair specialist. Quality materials and craftsmanship for lasting results.",
      verifiedServices: [
        'Furniture Repair',
        'Custom Work',
        'Installations',
        'Maintenance',
      ],
    ),
    // Painters
    'painter-1': ProfessionalProfileData(
      from: 'Colombo 07',
      qualifications: 'Painting & Decorating NVQ',
      avgResponseTime: '3-6 Minutes',
      description:
          "Roshan - 10+ years painting experience. Interior and exterior. Flawless finishes, quality paints.",
      verifiedServices: [
        'Interior Painting',
        'Exterior Painting',
        'Wall Preparation',
        'Touch-ups',
      ],
    ),
    'painter-2': ProfessionalProfileData(
      from: 'Colombo 04',
      qualifications: 'NVQ-L2 Painting',
      avgResponseTime: '5-10 Minutes',
      description:
          "Sajeewani - professional painter. Residential and commercial. Neat work and attention to detail.",
      verifiedServices: [
        'Residential Painting',
        'Commercial',
        'Wallpaper',
        'Decorative Finishes',
      ],
    ),
    'painter-3': ProfessionalProfileData(
      from: 'Colombo 05',
      qualifications: 'C&G Painting',
      avgResponseTime: '2-5 Minutes',
      description:
          "Nuwan - expert painter for interiors and exteriors. Color consultation and quality finishes.",
      verifiedServices: [
        'Interior/Exterior',
        'Color Consult',
        'Wall Painting',
        'Repairs',
      ],
    ),
    'painter-4': ProfessionalProfileData(
      from: 'Colombo 06',
      qualifications: 'NVQ-L3',
      avgResponseTime: '7-12 Minutes',
      description:
          "Dilhani - reliable painter. Full repaints, touch-ups, and decorative painting. Satisfied customers.",
      verifiedServices: [
        'Full Repaints',
        'Touch-ups',
        'Decorative',
        'Wall Prep',
      ],
    ),
    'painter-5': ProfessionalProfileData(
      from: 'Cinnamon Gardens',
      qualifications: 'Painting Diploma',
      avgResponseTime: '9-15 Minutes',
      description:
          "Lasantha - experienced painter. Quality materials, clean work, and durable finishes for your space.",
      verifiedServices: [
        'Interior Painting',
        'Exterior',
        'Texture Work',
        'Maintenance',
      ],
    ),
  };
}
