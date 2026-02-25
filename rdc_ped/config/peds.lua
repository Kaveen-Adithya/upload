-- Global Ped List Configuration
Peds = {

    -- Police Peds
    {
        label = 'Police Officer',
        model = 's_m_y_cop_01',
        category = 'police',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/s_m_y_cop_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'male',
        description = 'Standard police officer uniform'
    },
    {
        label = 'Police Female Officer',
        model = 's_f_y_cop_01',
        category = 'police',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/s_f_y_cop_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'female',
        description = 'Standard female police officer uniform'
    },
    {
        label = 'SWAT Officer',
        model = 's_m_y_swat_01',
        category = 'police',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/s_m_y_swat_01.jpg',
        restricted = true,
        minTier = 'senioradmin',
        gender = 'male',
        description = 'SWAT tactical gear'
    },

    -- EMS/Paramedic Peds
    {
        label = 'Paramedic',
        model = 's_m_m_paramedic_01',
        category = 'ems',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/s_m_m_paramedic_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'male',
        description = 'Standard paramedic uniform'
    },
    {
        label = 'Female Paramedic',
        model = 's_f_y_paramedic_01',
        category = 'ems',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/s_f_y_paramedic_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'female',
        description = 'Standard female paramedic uniform'
    },

    -- Fire Department Peds
    {
        label = 'Firefighter',
        model = 's_m_y_fireman_01',
        category = 'fire',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/s_m_y_fireman_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'male',
        description = 'Fire department gear'
    },

    -- Gang Peds
    {
        label = 'Gang Member',
        model = 'g_m_y_ballaeast_01',
        category = 'gang',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/g_m_y_ballaeast_01.jpg',
        restricted = true,
        minTier = 'mod',
        gender = 'male',
        description = 'Gang member clothing'
    },
    {
        label = 'Ballas Gang Member',
        model = 'g_m_y_ballaorig_01',
        category = 'gang',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/g_m_y_ballaorig_01.jpg',
        restricted = true,
        minTier = 'mod',
        gender = 'male',
        description = 'Ballas gang member'
    },

    -- Civilian Peds
    {
        label = 'Business Man',
        model = 'u_m_y_business_01',
        category = 'civilian',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/u_m_y_business_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'male',
        description = 'Formal business attire'
    },
    {
        label = 'Business Woman',
        model = 'u_f_y_business_01',
        category = 'civilian',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/u_f_y_business_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'female',
        description = 'Formal business attire for women'
    },
    {
        label = 'Casual Male',
        model = 'a_m_y_beach_01',
        category = 'civilian',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/a_m_y_beach_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'male',
        description = 'Casual beach wear'
    },
    {
        label = 'Casual Female',
        model = 'a_f_y_beach_01',
        category = 'civilian',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/a_f_y_beach_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'female',
        description = 'Casual beach wear for women'
    },

    -- Staff Peds
    {
        label = 'Staff Mascot',
        model = 'ig_ramp_gang',
        category = 'staff',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/ig_ramp_gang.jpg',
        restricted = true,
        minTier = 'admin',
        gender = 'male',
        description = 'Special staff mascot character'
    },
    {
        label = 'VIP Host',
        model = 'ig_solomon',
        category = 'staff',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/ig_solomon.jpg',
        restricted = true,
        minTier = 'headadmin',
        gender = 'male',
        description = 'VIP event host character'
    },

    -- Animal Peds
    {
        label = 'Husky Dog',
        model = 'a_c_husky',
        category = 'animals',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/a_c_husky.jpg',
        restricted = false,
        minTier = nil,
        gender = 'none',
        description = 'Friendly husky companion'
    },
    {
        label = 'Cat',
        model = 'a_c_cat_01',
        category = 'animals',
        image = 'https://cdn.jsdelivr.net/gh/justalemon/RedM-Clothing-Preview@master/images/peds/a_c_cat_01.jpg',
        restricted = false,
        minTier = nil,
        gender = 'none',
        description = 'Domestic cat companion'
    }
}