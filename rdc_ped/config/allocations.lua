-- Ped Allocations Configuration
-- Format: [identifier] = {allowedPedModels = {}, allowedCategories = {}, maxCount = 5, note = ""}
Allocations = {
    -- Example allocation by Discord ID
    ['123456789012345678'] = {
        allowedPedModels = {
            's_m_y_cop_01',
            's_f_y_cop_01',
            's_m_m_paramedic_01',
            's_f_y_paramedic_01',
            'u_m_y_business_01',
            'u_f_y_business_01'
        },
        allowedCategories = {'police', 'ems', 'civilian'},
        maxCount = 10,
        note = 'Senior Admin - John Doe'
    },
    
    -- Example allocation by License ID
    ['license:1234567890abcdef1234567890abcdef12345678'] = {
        allowedPedModels = {
            'a_m_y_beach_01',
            'a_f_y_beach_01',
            'u_m_y_business_01'
        },
        allowedCategories = {'civilian'},
        maxCount = 5,
        note = 'Helper - Jane Smith'
    },
    
    -- Another example with Discord ID
    ['987654321098765432'] = {
        allowedPedModels = {
            'ig_ramp_gang',
            'ig_solomon'
        },
        allowedCategories = {'staff'},
        maxCount = 2,
        note = 'Head Admin - Bob Wilson'
    },
    
    -- Example for Trial Moderator with limited access
    ['111222333444555666'] = {
        allowedPedModels = {
            's_m_y_cop_01',
            's_m_m_paramedic_01'
        },
        allowedCategories = {},
        maxCount = 3,
        note = 'Trial Mod - Alice Johnson'
    }
}