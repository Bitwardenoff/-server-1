﻿CREATE PROCEDURE [dbo].[User_DeleteById]
    @Id UNIQUEIDENTIFIER
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @BatchSize INT = 100

    -- Delete ciphers
    WHILE @BatchSize > 0
    BEGIN
        BEGIN TRANSACTION User_DeleteById_Ciphers

        DELETE TOP(@BatchSize)
        FROM
            [dbo].[Cipher]
        WHERE
            [UserId] = @Id

        SET @BatchSize = @@ROWCOUNT

        COMMIT TRANSACTION User_DeleteById_Ciphers
    END

    BEGIN TRANSACTION User_DeleteById

    -- Delete folders
    DELETE
    FROM
        [dbo].[Folder]
    WHERE
        [UserId] = @Id

    -- Delete AuthRequest, must be before Device
    DELETE
    FROM
        [dbo].[AuthRequest]
    WHERE 
        [UserId] = @Id

    -- Delete devices
    DELETE
    FROM
        [dbo].[Device]
    WHERE
        [UserId] = @Id

    -- Delete collection users
    DELETE
        CU
    FROM
        [dbo].[CollectionUser] CU
        INNER JOIN
        [dbo].[OrganizationUser] OU ON OU.[Id] = CU.[OrganizationUserId]
    WHERE
        OU.[UserId] = @Id

    -- Delete group users
    DELETE
        GU
    FROM
        [dbo].[GroupUser] GU
        INNER JOIN
        [dbo].[OrganizationUser] OU ON OU.[Id] = GU.[OrganizationUserId]
    WHERE
        OU.[UserId] = @Id

    -- Delete AccessPolicy
    DELETE
        AP
    FROM
        [dbo].[AccessPolicy] AP
        INNER JOIN
        [dbo].[OrganizationUser] OU ON OU.[Id] = AP.[OrganizationUserId]
    WHERE
        [UserId] = @Id

    -- Delete organization users
    DELETE
    FROM
        [dbo].[OrganizationUser]
    WHERE
        [UserId] = @Id

    -- Delete provider users
    DELETE
    FROM
        [dbo].[ProviderUser]
    WHERE
        [UserId] = @Id

    -- Delete SSO Users
    DELETE
    FROM
        [dbo].[SsoUser]
    WHERE
        [UserId] = @Id

    -- Delete Emergency Accesses
    DELETE
    FROM
        [dbo].[EmergencyAccess]
    WHERE
        [GrantorId] = @Id
        OR
        [GranteeId] = @Id

    -- Delete Sends
    DELETE
    FROM
        [dbo].[Send]
    WHERE 
        [UserId] = @Id

    -- Finally, delete the user
    DELETE
    FROM
        [dbo].[User]
    WHERE
        [Id] = @Id

    COMMIT TRANSACTION User_DeleteById
END
